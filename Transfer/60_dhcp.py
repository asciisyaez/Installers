import subprocess
import logging
import json
import time
import os
import sys

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    filename=os.path.dirname(os.path.realpath(__file__)) + '/dhcp.log',
                    filemode='a')

ps_script = """
$Server = Hostname
$ScopeList = Get-DhcpServerv4Scope -ComputerName $Server

ForEach($Scope in $ScopeList.ScopeID) {
    Try {
        $ScopeInfo = Get-DhcpServerv4Scope -ComputerName $Server -ScopeId $Scope
        $ScopeStats = Get-DhcpServerv4ScopeStatistics -ComputerName $Server -ScopeId $Scope | Select ScopeID,PercentageInUse
        $percentageofusage = $ScopeStats.PercentageInUse
        $pool = $ScopeInfo.ScopeId.IPAddressToString
        Write-Host("$($pool),$($percentageofusage)")
    } Catch {
    }
}
"""

#Create the approriate metrics needed by Open-Falcon
def makeMetric(scope_id = '', value = 0):
    metric = {
        'metric': "dhcp.stat.utilization",
        'timestamp': int(time.time()),
        'value': float(value),
        'tags': 'address=%s'%(scope_id),
        'step': 60
        }
    return metric

#Manipulate the data from powershell
def parseData(data):
    metrices = []
    for line in data.strip().split("\n"):
        lineSplit = line.split(",")
        metrices.append(makeMetric(lineSplit[0], lineSplit[1]))
    return metrices

def run(script):
    output = subprocess.run(["powershell", "-Command", script], capture_output=True)
    if output.returncode != 0:
        logging.error("Error extracting data from Powershell")
    else:
        print(json.dumps(parseData(output.stdout.decode("utf-8"))))

run(ps_script)
