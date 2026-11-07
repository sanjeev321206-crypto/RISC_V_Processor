
#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RTL_DIR="$ROOT_DIR/rtl"
TEST_DIR="$ROOT_DIR/testbench"
BUILD_DIR="$ROOT_DIR/build"

mkdir -p "$BUILD_DIR"

PASS_COUNT=0
FAIL_COUNT=0

mapfile -t SOURCES < <(
    find "$RTL_DIR" -maxdepth 1 -type f -name '*.v' \
        ! -name 'riscv_datapath*' | sort
)

echo "=========================================="
echo "       RISC-V CPU REGRESSION TESTS"
echo "=========================================="

for tb_file in "$TEST_DIR"/*_tb.v; do
    [[ -f "$tb_file" ]] || continue

    tb_name=$(basename "$tb_file" .v)

    tb_module=$(grep -m1 -E '^[[:space:]]*module[[:space:]]+' \
        "$tb_file" | sed -E 's/^[[:space:]]*module[[:space:]]+([a-zA-Z0-9_]+).*/\1/')

    if [[ -z "$tb_module" ]]; then
        echo "[FAIL] Cannot identify module in $tb_file"
        ((FAIL_COUNT++))
        continue
    fi

    echo ""
    echo "Running: $tb_name"

    if ! iverilog -g2012 -s "$tb_module" \
        -o "$BUILD_DIR/$tb_name" \
        "${SOURCES[@]}" "$tb_file"; then

        echo "[FAIL] Compilation: $tb_name"
        ((FAIL_COUNT++))
        continue
    fi

    OUTPUT=$(vvp "$BUILD_DIR/$tb_name" 2>&1)
    SIM_STATUS=$?

    echo "$OUTPUT"

    if [[ "$SIM_STATUS" -ne 0 ]] ||
       echo "$OUTPUT" | grep -Eiq \
       'TEST FAILED|ERROR[[:space:]]*:[[:space:]]*[1-9][0-9]*|Errors detected:[[:space:]]*[1-9][0-9]*|RESET TESTS FAILED'; then

        echo "[FAIL] $tb_name"
        ((FAIL_COUNT++))
    else
        echo "[PASS] $tb_name"
        ((PASS_COUNT++))
    fi
done

echo ""
echo "=========================================="
echo "          FINAL TEST SUMMARY"
echo "=========================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "=========================================="

if [[ "$FAIL_COUNT" -eq 0 ]]; then
    echo "ALL TESTS PASSED!"
else
    echo "SOME TESTS FAILED. CHECK OUTPUT."
fi

exit "$FAIL_COUNT"
