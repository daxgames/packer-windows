write-host "==> 'enable-winrm.ps1' - START..."
write-host "====> Getting Connections..."
$NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$Connections = $NetworkListManager.GetNetworkConnections()
$Connections | ForEach-Object { $_.GetNetwork().SetCategory(1) }

write-host "====> Enable PSRemoting..."
Enable-PSRemoting -Force

write-host "====> WINRM Quick Config..."
winrm quickconfig -q
winrm quickconfig -transport:http

write-host "====> WINRM Set Config..."
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

write-host "====> Configure Firewall..."
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow remoteip=any
write-host "====> Set WINRM Service Statup..."
Set-Service winrm -startuptype "auto"
write-host "====> Restart WINRM Service..."
Restart-Service winrm
write-host "==> 'enable-winrm.ps1' - END..."
start-sleep 200000
