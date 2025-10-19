#!/bin/bash

echo "=== Renode Documentation and Docker Investigation ==="
echo "Checking official Renode usage patterns and Docker integration"
echo

echo "1. Checking Renode installation and basic info..."
renode --version
echo

echo "2. Checking available Renode platforms..."
echo "Looking for STM32F4 platforms..."
find /opt -name "*.repl" -path "*/platforms/*" 2>/dev/null | grep -i stm32 | head -10
echo

echo "3. Checking Renode help and options..."
renode --help | head -20
echo

echo "4. Testing Renode with minimal script..."
cat > /tmp/minimal_test.resc << 'EOF'
# Minimal Renode test
echo "Renode is working"
quit
EOF

echo "Running minimal test..."
renode --disable-xwt /tmp/minimal_test.resc
echo "Minimal test exit code: $?"
echo

echo "5. Checking Renode Docker official examples..."
echo "Official Renode Docker usage patterns:"
echo

cat << 'EOF'
According to Renode documentation, the recommended Docker usage is:

# Official Renode Docker image
docker run --rm -it renode/renode:latest

# For headless operation
docker run --rm -it renode/renode:latest renode --disable-xwt script.resc

# With volume mounting
docker run --rm -it -v $(pwd):/workspace renode/renode:latest

# For semihosting, the correct approach is:
1. Use proper platform files
2. Enable semihosting in the script
3. Use correct CPU initialization
EOF

echo
echo "6. Investigating semihosting configuration..."
echo "Checking if semihosting analyzer is available..."

cat > /tmp/semihost_check.resc << 'EOF'
# Check semihosting capabilities
help sysbus.cpu
quit
EOF

echo "Checking CPU capabilities..."
renode --disable-xwt /tmp/semihost_check.resc 2>&1 | grep -i semihost
echo

echo "7. Recommended next steps:"
echo "a) Try official Renode Docker image"
echo "b) Use proper STM32F4 platform files"
echo "c) Check semihosting configuration syntax"
echo "d) Verify binary format compatibility"
echo

echo "=== Investigation Summary ==="
echo "This investigation helps identify:"
echo "- Correct Renode installation"
echo "- Available platform files"
echo "- Proper Docker usage patterns"
echo "- Semihosting configuration requirements"