#!/bin/bash
# BloodPulse Test-Fix Loop Script
# Max 5 iterations - stops if all tests pass or max iterations reached

set -e

PROJECT_DIR="/shared/build/artifacts/bloodpulse"
TEST_RESULTS_DIR="$PROJECT_DIR/test-results"
MAX_ITERATIONS=5
ITERATION=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

mkdir -p "$TEST_RESULTS_DIR"

log() {
    echo -e "${BLUE}[$(date -u +'%Y-%m-%dT%H:%M:%SZ')]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

update_status() {
    local status=$1
    local iteration=$2
    local message=$3
    
    cat > /shared/pipeline/agent_status.json <<EOF
{
  "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "agent": "builder_mobile",
  "status": "$status",
  "task_id": "task-004",
  "action": "TEST_FIX_LOOP",
  "iteration": $iteration,
  "max_iterations": $MAX_ITERATIONS,
  "message": "$message"
}
EOF
}

run_tests() {
    log "Running tests (flutter test)..."
    cd "$PROJECT_DIR"
    
    # Run unit/widget tests first
    if flutter test --reporter json 2>&1 | tee "$TEST_RESULTS_DIR/test_output_$ITERATION.json"; then
        log_success "Unit tests passed"
        return 0
    else
        log_error "Tests failed - see $TEST_RESULTS_DIR/test_output_$ITERATION.json"
        return 1
    fi
}

build_apk() {
    log "Building release APK (iteration $ITERATION)..."
    cd "$PROJECT_DIR"
    
    # Clean previous build
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Build release APK
    if flutter build apk --release --target-platform android-arm64 2>&1 | tee "$TEST_RESULTS_DIR/build_$ITERATION.log"; then
        log_success "APK built successfully"
        cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk" "$TEST_RESULTS_DIR/app-release-iter-$ITERATION.apk"
        return 0
    else
        log_error "Build failed - see $TEST_RESULTS_DIR/build_$ITERATION.log"
        return 1
    fi
}

analyze_failure() {
    log "Analyzing test failures..."
    
    # Check build logs for common errors
    if grep -q "auth_repository.dart" "$TEST_RESULTS_DIR/build_$ITERATION.log" 2>/dev/null; then
        log_warn "Auth repository issues detected"
        return 1
    fi
    
    if grep -q "auth_bloc.dart" "$TEST_RESULTS_DIR/build_$ITERATION.log" 2>/dev/null; then
        log_warn "Auth bloc issues detected"
        return 1
    fi
    
    return 0
}

apply_fix() {
    log "Applying automated fixes for iteration $ITERATION..."
    
    # This is where automated fixes would be applied
    # For now, we rely on the code already being fixed
    log "No automated fixes needed - code should be correct"
    
    return 0
}

# Main test-fix loop
main() {
    log "Starting Test-Fix Loop (max $MAX_ITERATIONS iterations)"
    
    while [ $ITERATION -lt $MAX_ITERATIONS ]; do
        ITERATION=$((ITERATION + 1))
        
        log "========== ITERATION $ITERATION/$MAX_ITERATIONS =========="
        update_status "in_progress" $ITERATION "Building and testing (iteration $ITERATION)"
        
        # Step 1: Build
        if ! build_apk; then
            log_error "Build failed in iteration $ITERATION"
            
            # Try to fix and continue
            if ! apply_fix; then
                log_error "Could not apply fix"
                continue
            fi
            
            # Rebuild after fix
            if ! build_apk; then
                log_error "Build still failing after fix attempt"
                continue
            fi
        fi
        
        # Step 2: Test
        if run_tests; then
            log_success "ALL TESTS PASSED in iteration $ITERATION!"
            
            # Copy final APK
            cp "$TEST_RESULTS_DIR/app-release-iter-$ITERATION.apk" "$PROJECT_DIR/app-release.apk"
            
            # Create success report
            cat > "$TEST_RESULTS_DIR/final_report.json" <<EOF
{
  "status": "success",
  "iterations": $ITERATION,
  "max_iterations": $MAX_ITERATIONS,
  "final_apk": "$PROJECT_DIR/app-release.apk",
  "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "tests_passed": true
}
EOF
            
            update_status "complete" $ITERATION "All tests passed - APK delivered"
            
            log_success "Test-Fix Loop COMPLETE!"
            log "Final APK: $PROJECT_DIR/app-release.apk"
            exit 0
        else
            log_warn "Tests failed in iteration $ITERATION"
            
            # Analyze and fix
            if analyze_failure; then
                log "Attempting fix..."
                if ! apply_fix; then
                    log_error "Fix application failed"
                fi
            fi
        fi
        
        log "Iteration $ITERATION complete - continuing to next iteration..."
    done
    
    # Max iterations reached without success
    log_error "MAX ITERATIONS ($MAX_ITERATIONS) REACHED - Tests still failing"
    
    cat > "$TEST_RESULTS_DIR/final_report.json" <<EOF
{
  "status": "failure",
  "iterations": $ITERATION,
  "max_iterations": $MAX_ITERATIONS,
  "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "tests_passed": false,
  "error": "Max iterations reached without test success"
}
EOF
    
    update_status "failed" $ITERATION "Max iterations reached - manual intervention needed"
    
    exit 1
}

# Run main loop
main "$@"