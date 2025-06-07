@echo off
REM Cleanup Script for Language Benchmark Suite (Windows)
REM Removes all generated files: test data, compiled binaries, results, and temporary files

echo 🧹 Language Benchmark Suite Cleanup (Windows)
echo ===============================================

echo.

echo 📊 Removing Test Data Files
echo ===========================
if exist test_data.csv (
    echo 🗑️  Removing main test dataset...
    del test_data.csv
    echo ✅ Removed: test_data.csv
) else (
    echo ℹ️  test_data.csv not found (already clean)
)

if exist test_*.csv (
    echo 🗑️  Removing temporary test files...
    del test_*.csv
    echo ✅ Removed temporary test files
)

echo.

echo 🔧 Removing Compiled Binaries
echo ==============================

echo ☕ Java bytecode files:
if exist java\*.class (
    echo 🗑️  Removing Java .class files...
    del java\*.class
    echo ✅ Removed all Java .class files
) else (
    echo ℹ️  No Java .class files found
)

echo 🐹 Go binaries:
if exist go\mergesort_go.exe (
    echo 🗑️  Removing Go sequential binary...
    del go\mergesort_go.exe
    echo ✅ Removed: go\mergesort_go.exe
) else if exist go\mergesort_go (
    echo 🗑️  Removing Go sequential binary...
    del go\mergesort_go
    echo ✅ Removed: go\mergesort_go
) else (
    echo ℹ️  Go sequential binary not found
)

if exist go\mergesort_go_optimized.exe (
    echo 🗑️  Removing Go optimized binary...
    del go\mergesort_go_optimized.exe
    echo ✅ Removed: go\mergesort_go_optimized.exe
) else if exist go\mergesort_go_optimized (
    echo 🗑️  Removing Go optimized binary...
    del go\mergesort_go_optimized
    echo ✅ Removed: go\mergesort_go_optimized
) else (
    echo ℹ️  Go optimized binary not found
)

echo 🦀 Rust binaries:
if exist rust\mergesort_rust.exe (
    echo 🗑️  Removing Rust binary...
    del rust\mergesort_rust.exe
    echo ✅ Removed: rust\mergesort_rust.exe
) else if exist rust\mergesort_rust (
    echo 🗑️  Removing Rust binary...
    del rust\mergesort_rust
    echo ✅ Removed: rust\mergesort_rust
) else (
    echo ℹ️  Rust binary not found
)

echo ⚡ C binaries:
if exist c\mergesort_c.exe (
    echo 🗑️  Removing C sequential binary...
    del c\mergesort_c.exe
    echo ✅ Removed: c\mergesort_c.exe
) else if exist c\mergesort_c (
    echo 🗑️  Removing C sequential binary...
    del c\mergesort_c
    echo ✅ Removed: c\mergesort_c
) else (
    echo ℹ️  C sequential binary not found
)

if exist c\parallel_mergesort_c.exe (
    echo 🗑️  Removing C parallel binary...
    del c\parallel_mergesort_c.exe
    echo ✅ Removed: c\parallel_mergesort_c.exe
) else if exist c\parallel_mergesort_c (
    echo 🗑️  Removing C parallel binary...
    del c\parallel_mergesort_c
    echo ✅ Removed: c\parallel_mergesort_c
) else (
    echo ℹ️  C parallel binary not found
)

echo.

echo 📁 Removing Results and Reports
echo ===============================
if exist results (
    echo 🗑️  Cleaning results directory (keeping .gitignore)...
    for %%f in (results\*) do (
        if not "%%~nxf"==".gitignore" (
            del "%%f"
        )
    )
    echo ✅ Cleaned results directory
) else (
    echo ℹ️  Results directory not found
)

echo.

echo 🧹 Removing Temporary Files
echo ===========================

if exist *.tmp (
    echo 🗑️  Removing temporary files...
    del *.tmp
    echo ✅ Removed temporary files
)

if exist *.log (
    echo 🗑️  Removing log files...
    del *.log
    echo ✅ Removed log files
)

if exist *~ (
    echo 🗑️  Removing backup files...
    del *~
    echo ✅ Removed backup files
)

if exist Thumbs.db (
    echo 🗑️  Removing Windows system files...
    del Thumbs.db
    echo ✅ Removed Thumbs.db
)

if exist desktop.ini (
    del desktop.ini
)

echo.

echo 📦 Language-Specific Cleanup
echo ============================

echo 🟨 Node.js modules:
if exist node_modules (
    echo 🗑️  Removing Node.js dependencies...
    rmdir /s /q node_modules
    echo ✅ Removed node_modules
)

if exist package-lock.json (
    echo 🗑️  Removing Node.js lock file...
    del package-lock.json
    echo ✅ Removed package-lock.json
)

echo 🦀 Rust target directory:
if exist target (
    echo 🗑️  Removing Rust build artifacts...
    rmdir /s /q target
    echo ✅ Removed target directory
)

echo 🐍 Python cache files:
if exist __pycache__ (
    echo 🗑️  Removing Python cache...
    rmdir /s /q __pycache__
    echo ✅ Removed __pycache__
)

if exist *.pyc (
    echo 🗑️  Removing Python bytecode...
    del *.pyc
    echo ✅ Removed .pyc files
)

echo.

echo 🎯 Cleanup Summary
echo ==================
echo ✅ Cleanup completed successfully!
echo.
echo 📋 What was cleaned:
echo    • Test data files (CSV)
echo    • Compiled binaries (Java, Go, Rust, C)
echo    • Results and reports (JSON, TXT)
echo    • Temporary and cache files
echo    • Language-specific build artifacts
echo.
echo 📂 Preserved files:
echo    • Source code (.java, .go, .rs, .c, .js, .py)
echo    • Configuration files (Dockerfile, .gitignore)
echo    • Documentation (README.md, docs/)
echo    • Build scripts (.sh, .bat)
echo.
echo 💡 Tip: Run build_and_test.bat to rebuild everything
echo 💡 Or run python benchmark.py to regenerate test data

pause 