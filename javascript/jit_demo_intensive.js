#!/usr/bin/env node

// More JIT-sensitive computational benchmark
function mandelbrotIteration(cx, cy, maxIter = 1000) {
    let x = 0, y = 0;
    let xx = 0, yy = 0;
    
    for (let i = 0; i < maxIter; i++) {
        if (xx + yy > 4) return i;
        
        const temp = xx - yy + cx;
        y = 2 * x * y + cy;
        x = temp;
        xx = x * x;
        yy = y * y;
    }
    return maxIter;
}

function complexMath(n) {
    let result = 0;
    for (let i = 0; i < n; i++) {
        const angle = i * 0.001;
        result += Math.sin(angle) * Math.cos(angle) * Math.sqrt(i);
        result += Math.log(i + 1) * Math.exp(-angle);
    }
    return result;
}

function polymorphicOperations(objects) {
    let total = 0;
    for (const obj of objects) {
        // This creates polymorphic call sites that JIT can optimize
        total += obj.compute();
    }
    return total;
}

// Create different object types for polymorphic test
class TypeA {
    constructor(value) { this.value = value; }
    compute() { return this.value * 2 + 1; }
}

class TypeB {
    constructor(value) { this.value = value; }
    compute() { return this.value * 3 - 1; }
}

class TypeC {
    constructor(value) { this.value = value; }
    compute() { return Math.sin(this.value) * 100; }
}

function getV8Flags() {
    const flags = process.execArgv;
    if (flags.length === 0) {
        return "JIT Enabled (Default)";
    }
    return `JIT Disabled: ${flags.join(' ')}`;
}

function runCPUIntensiveBenchmark() {
    console.log("[JIT-INTENSIVE] CPU-Intensive JIT Benchmark");
    console.log(`Configuration: ${getV8Flags()}`);
    console.log("=" * 40);
    
    // Test 1: Mandelbrot computation
    console.log("Test 1: Mandelbrot Set Computation");
    const mandelbrotStart = Date.now();
    let mandelbrotResult = 0;
    
    for (let y = -2; y < 2; y += 0.01) {
        for (let x = -2; x < 2; x += 0.01) {
            mandelbrotResult += mandelbrotIteration(x, y, 100);
        }
    }
    
    const mandelbrotTime = (Date.now() - mandelbrotStart) / 1000;
    console.log(`   Completed in ${mandelbrotTime.toFixed(4)}s (result: ${mandelbrotResult})`);
    
    // Test 2: Complex mathematical operations
    console.log("Test 2: Complex Mathematical Operations");
    const mathStart = Date.now();
    const mathResult = complexMath(1000000);
    const mathTime = (Date.now() - mathStart) / 1000;
    console.log(`   Completed in ${mathTime.toFixed(4)}s (result: ${mathResult.toFixed(2)})`);
    
    // Test 3: Polymorphic operations
    console.log("Test 3: Polymorphic Object Operations");
    const objects = [];
    for (let i = 0; i < 100000; i++) {
        if (i % 3 === 0) objects.push(new TypeA(i));
        else if (i % 3 === 1) objects.push(new TypeB(i));
        else objects.push(new TypeC(i));
    }
    
    const polyStart = Date.now();
    const polyResult = polymorphicOperations(objects);
    const polyTime = (Date.now() - polyStart) / 1000;
    console.log(`   Completed in ${polyTime.toFixed(4)}s (result: ${polyResult.toFixed(2)})`);
    
    const totalTime = mandelbrotTime + mathTime + polyTime;
    console.log(`\nTotal execution time: ${totalTime.toFixed(4)}s`);
    
    return totalTime;
}

if (require.main === module) {
    runCPUIntensiveBenchmark();
} 