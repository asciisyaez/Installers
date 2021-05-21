logger:
  dir: logs/collector
  level: WARNING
  keepHours: 2

identity:
  specify: "ENDPOINT_NAME"

ip:
  specify: ""

enable:
  report: true

stra:
  api: /api/mon/collects/ # n9e v3 Using this address, n9e v2 can be configured without the stra part, or with /api/portal/collects/

report:
  # To call the interface of ams to report data, the token of ams is required
  token: GarenaInfaAmsToken

  # Report period, in seconds
  interval: 60

  # physical: physical machine, virtual: virtual machine, container: container, switch: switch
  cate: windows virtual

  # Which field to use as the only KEY, that is, as the where condition to update the corresponding record, generally use sn or ip
  uniqkey: ip

  # If it is a virtual machine, it should get uuid
  # curl -s http://169.254.169.254/a/meta-data/instance-id
  #sn: Get-WmiObject win32_bios | select Serialnumber
  sn: (Get-WmiObject -ComputerName $env:ComputerName -Class Win32_BIOS).SerialNumber

  fields:
    cpu: (Get-WmiObject -class Win32_ComputerSystem).numberoflogicalprocessors
    mem: Write-Host $('{0:f2}' -f ((Get-WmiObject -class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum/(1024*1024*1024)))Gi
    disk: Write-Host $('{0:f2}' -f ((Get-WmiObject Win32_LogicalDisk -ComputerName $env:ComputerName -Filter "DeviceID='C:'" | Select-Object Size).Size/(1024*1024*1024)))Gi

sys:
  # timeout in ms
  # interval in second
  timeout: 1000
  interval: 20
  ifacePrefix:
    - Ethernet
  mountPoint: []
  mountIgnorePrefix:
    - /var/lib
  ntpServers:
    - time.google.com
  plugin: plugin/
  ignoreMetrics:
    - cpu.core.idle
    - cpu.core.util
    - cpu.core.sys
    - cpu.core.user
    - cpu.core.irq
