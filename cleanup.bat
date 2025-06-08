@echo off
REM Cleanup Script for Language Benchmark Suite (Windows)
REM Removes all generated files: test data, compiled binaries, results, and temporary files

echo [CLEANUP] Language Benchmark Suite Cleanup (Windows)
echo ===============================================

echo.

echo [DATA] Removing Test Data Files
echo ===========================
if exist test_data.csv (
    echo [DELETE] Removing main test dataset...
    del test_data.csv
    echo [DONE] Removed: test_data.csv
) else (
    echo [INFO] test_data.csv not found (already clean)
)

if exist test_*.csv (
    echo [DELETE] Removing temporary test files...
    del test_*.csv
    echo [DONE] Removed temporary test files
)

echo.

echo [BINARIES] Removing Compiled Binaries
echo ==============================

echo [JAVA] Java bytecode files:
if exist java\*.class (
    echo [DELETE] Removing Java .class files...
    del java\*.class
    echo [DONE] Removed all Java .class files
) else (
    echo [INFO] No Java .class files found
)

echo [GO] Go binaries:
if exist go\mergesort_go.exe (
    echo [DELETE] Removing Go sequential binary...
    del go\mergesort_go.exe
    echo [DONE] Removed: go\mergesort_go.exe
) else if exist go\mergesort_go (
    echo [DELETE] Removing Go sequential binary...
    del go\mergesort_go
    echo [DONE] Removed: go\mergesort_go
) else (
    echo [INFO] Go sequential binary not found
)

if exist go\mergesort_go_optimized.exe (
    echo [DELETE] Removing Go optimized binary...
    del go\mergesort_go_optimized.exe
    echo [DONE] Removed: go\mergesort_go_optimized.exe
) else if exist go\mergesort_go_optimized (
    echo [DELETE] Removing Go optimized binary...
    del go\mergesort_go_optimized
    echo [DONE] Removed: go\mergesort_go_optimized
) else (
    echo [INFO] Go optimized binary not found
)

echo [RUST] Rust binaries:
if exist rust\mergesort_rust.exe (
    echo [DELETE] Removing Rust sequential binary...
    del rust\mergesort_rust.exe
    echo [DONE] Removed: rust\mergesort_rust.exe
) else if exist rust\mergesort_rust (
    echo [DELETE] Removing Rust sequential binary...
    del rust\mergesort_rust
    echo [DONE] Removed: rust\mergesort_rust
) else (
    echo [INFO] Rust sequential binary not found
)

if exist rust\parallel_mergesort_rust.exe (
    echo [DELETE] Removing Rust parallel binary...
    del rust\parallel_mergesort_rust.exe
    echo [DONE] Removed: rust\parallel_mergesort_rust.exe
) else if exist rust\parallel_mergesort_rust (
    echo [DELETE] Removing Rust parallel binary...
    del rust\parallel_mergesort_rust
    echo [DONE] Removed: rust\parallel_mergesort_rust
) else (
    echo [INFO] Rust parallel binary not found
)

REM Additional Rust cleanup - check for debug and release binaries
if exist rust\target\debug\mergesort_rust.exe (
    echo [DELETE] Removing Rust debug sequential binary...
    del rust\target\debug\mergesort_rust.exe
    echo [DONE] Removed: rust\target\debug\mergesort_rust.exe
)

if exist rust\target\debug\parallel_mergesort_rust.exe (
    echo [DELETE] Removing Rust debug parallel binary...
    del rust\target\debug\parallel_mergesort_rust.exe
    echo [DONE] Removed: rust\target\debug\parallel_mergesort_rust.exe
)

if exist rust\target\release\mergesort_rust.exe (
    echo [DELETE] Removing Rust release sequential binary...
    del rust\target\release\mergesort_rust.exe
    echo [DONE] Removed: rust\target\release\mergesort_rust.exe
)

if exist rust\target\release\parallel_mergesort_rust.exe (
    echo [DELETE] Removing Rust release parallel binary...
    del rust\target\release\parallel_mergesort_rust.exe
    echo [DONE] Removed: rust\target\release\parallel_mergesort_rust.exe
)

echo [C] C binaries:
if exist c\mergesort_c.exe (
    echo [DELETE] Removing C sequential binary...
    del c\mergesort_c.exe
    echo [DONE] Removed: c\mergesort_c.exe
) else if exist c\mergesort_c (
    echo [DELETE] Removing C sequential binary...
    del c\mergesort_c
    echo [DONE] Removed: c\mergesort_c
) else (
    echo [INFO] C sequential binary not found
)

if exist c\parallel_mergesort_c.exe (
    echo [DELETE] Removing C parallel binary...
    del c\parallel_mergesort_c.exe
    echo [DONE] Removed: c\parallel_mergesort_c.exe
) else if exist c\parallel_mergesort_c (
    echo [DELETE] Removing C parallel binary...
    del c\parallel_mergesort_c
    echo [DONE] Removed: c\parallel_mergesort_c
) else (
    echo [INFO] C parallel binary not found
)

echo.

echo [RESULTS] Removing Results and Reports
echo ===============================
if exist results (
    echo [DELETE] Cleaning results directory (keeping .gitignore)...
    
    REM Remove all files except .gitignore
    for %%f in (results\*.*) do (
        if not "%%~nxf"==".gitignore" (
            del "%%f" 2>nul
        )
    )
    
    REM Remove subdirectories in results folder
    for /d %%d in (results\*) do (
        rmdir /s /q "%%d" 2>nul
    )
    
    echo [DONE] Cleaned results directory
) else (
    echo [INFO] Results directory not found
)

echo.

echo [TEMP] Removing Temporary Files
echo ===========================

if exist *.tmp (
    echo [DELETE] Removing temporary files...
    del *.tmp
    echo [DONE] Removed temporary files
)

if exist *.log (
    echo [DELETE] Removing log files...
    del *.log
    echo [DONE] Removed log files
)

if exist *~ (
    echo [DELETE] Removing backup files...
    del *~
    echo [DONE] Removed backup files
)

if exist Thumbs.db (
    echo [DELETE] Removing Windows system files...
    del Thumbs.db
    echo [DONE] Removed Thumbs.db
)

if exist desktop.ini (
    del desktop.ini
)

echo.

echo [LANGUAGES] Language-Specific Cleanup
echo ============================

echo [NODE] Node.js modules:
if exist node_modules (
    echo [DELETE] Removing Node.js dependencies...
    rmdir /s /q node_modules
    echo [DONE] Removed node_modules
)

if exist package-lock.json (
    echo [DELETE] Removing Node.js lock file...
    del package-lock.json
    echo [DONE] Removed package-lock.json
)

echo [RUST] Rust target directory:
if exist rust\target (
    echo [DELETE] Removing Rust build artifacts...
    rmdir /s /q rust\target 2>nul
    if not exist rust\target (
        echo [DONE] Removed rust\target directory
    ) else (
        echo [WARNING] Could not remove rust\target directory (may be in use)
    )
) else (
    echo [INFO] rust\target directory not found
)

if exist target (
    echo [DELETE] Removing root target directory...
    rmdir /s /q target 2>nul
    if not exist target (
        echo [DONE] Removed target directory
    ) else (
        echo [WARNING] Could not remove target directory (may be in use)
    )
) else (
    echo [INFO] root target directory not found
)

echo [PYTHON] Python cache files:
if exist __pycache__ (
    echo [DELETE] Removing Python cache...
    rmdir /s /q __pycache__
    echo [DONE] Removed __pycache__
)

if exist *.pyc (
    echo [DELETE] Removing Python bytecode...
    del *.pyc
    echo [DONE] Removed .pyc files
)

echo.

echo [SUMMARY] Cleanup Summary
echo ==================
echo [SUCCESS] Cleanup completed successfully!
echo.
echo [CLEANED] What was cleaned:
echo    * Test data files (CSV)
echo    * Compiled binaries (Java, Go, Rust, C)
echo    * Results and reports (JSON, TXT)
echo    * Temporary and cache files
echo    * Language-specific build artifacts
echo.
echo [PRESERVED] Preserved files:
echo    * Source code (.java, .go, .rs, .c, .js, .py)
echo    * Configuration files (Dockerfile, .gitignore)
echo    * Documentation (README.md, docs/)
echo    * Build scripts (.sh, .bat)
echo.
echo [TIP] Run build_and_test.bat to rebuild everything
echo [TIP] Or run python benchmark.py to regenerate test data

pause 