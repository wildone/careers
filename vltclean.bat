@echo off
if "%1"=="" GOTO projectmissing
echo Cleaning VLT files ...
cd %1-ui
del /S .vlt >NUL 2>&1
cd ..
echo Building and installing FULL content package ...
call mvn clean install -Dmaven.test.skip=true -P %1,full >mvn.log
find /c /i "BUILD SUCCESS" <mvn.log >build_success.log
set /p BUILD_SUCCESSFUL= <build_success.log
if exist build_success.log del build_success.log
if %BUILD_SUCCESSFUL% == 1 (
  echo VLT checkout corporate-ui ...
  cd %1-ui\src\main\content\jcr_root
  call vlt --credentials admin:admin co http://localhost:4502/crx / . --force --quiet
  cd ..\..\..\..\..
  del %1-ui\src\main\content\jcr_root\apps\%1\install\%1-*.jar >NUL
  echo Cleanup finished.
  GOTO end
) else (
  type mvn.log
  echo Build was not successful, cleanup aborted.
  IF [%1] == [] pause
  GOTO end
)
:projectmissing
echo Project is missing. Please use project name as argument, e.g.:
echo vltclean.bat corporate 
:end
if exist mvn.log del mvn.log
(set BUILD_SUCCESSFUL=)