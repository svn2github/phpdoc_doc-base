@ECHO OFF
SET PHP_DOC_BASE_DIR=%~dp0
CALL "C:\php\binaries\PHP_5_3\php.exe" -d memory_limit=-1 "%PHP_DOC_BASE_DIR%\scripts\build-chms.php" %*
