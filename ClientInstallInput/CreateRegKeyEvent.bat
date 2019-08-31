@echo off
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Eventlog\Enabler /v EventMessageFile /t REG_SZ /d C:\Enabler\EnablerEvent.dll /f
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Eventlog\Enabler /v ParameterMessageFile /t REG_SZ /d C:\Enabler\EnablerEvent.dll /f
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Eventlog\Enabler /v Sources /t REG_SZ /d Enabler /f
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Eventlog\Enabler\Enabler /v EventMessageFile /t REG_SZ /d C:\Enabler\EnablerEvent.dll /f
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Eventlog\Enabler\Enabler /v ParameterMessageFile /t REG_SZ /d C:\Enabler\EnablerEvent.dll /f
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Eventlog\Enabler\Enabler /v Sources /t REG_SZ /d Enabler /f