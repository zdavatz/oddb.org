rem
echo zwei
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\C:\Program Files\TortoiseSVN\bin;C:\Program Files\GnuWin32\bin;E:\Programme\Git\cmd;E:\Programme\Git\bin;E:\Programme\git\bin;E:\Programme\Ruby193\bin
ruby -v
call bundle install --without debugger --gemfile Gemfile.watir
set ODDB_BROWSER=ie
rspec spec
