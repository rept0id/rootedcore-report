#!/bin/bash
mkdir /tmp/thriftcode
mkdir /tmp/thriftcode/html-report
cd /tmp/thriftcode/html-report
lspci > /tmp/thriftcode/html-report/pci.txt

version="thriftcode HTML report version 2.3"

function text_calculator
{
#parameters : text input, key word, bytes
if [ $# != 3 ]; then
    echo -e 'Error : function text_calculator works with 3 parameters... \nGiven parameters =' $#
fi
if [ $# == 3 ]; then
    bytes=$(cat $1 | grep "$2" | tail --lines=1 | wc --bytes)
    bytes=$(expr $bytes - $3)
    cat $1 | grep "$2" | tail --bytes=$bytes
fi
}

function iframe_source
{
#parameters : src_path, description, html output
#ex. iframe_source /tmp/hdd_stats.txt 'Here's my hdd stats:' '/tmp/hdd_stats.html'

# $1 is src
# $2 is description
# $3 is html_output
echo $1 && echo $2 && echo $3

cat /tmp/thriftcode/html-report/upstyle.txt > $3
cat /tmp/thriftcode/html-report/links_style.txt >> $3
cat /tmp/thriftcode/html-report/time.txt  >> $3
echo '<strong><u>'"$2"'</u></strong><br>' >> $3
echo '<iframe src='"$1"' width=1300 height=500></iframe><p>' >> $3
cat /tmp/thriftcode/html-report/downstyle.txt >> $3
}

#Pages source...
time=$(date +%d/%m/%y" "%H:%M)
echo '<!doctype html><html>
<head>
<title>Report</title>
<meta http-equiv="refresh" content="60">
<meta name="author" content="Radwan Ahmet">
</head>
<body bgcolor=#afafd1d17979>
<h1>'"$(hostname)"'</h1>' > /tmp/thriftcode/html-report/upstyle.txt

echo '<a href="index.html">Home page</a> &#10242 
<a href="printer.html">print details</a><br>' > /tmp/thriftcode/html-report/links_style.txt

echo '<em>last details update: '"$time"'</em><br><br>' > /tmp/thriftcode/html-report/time.txt

echo '<br><a href="index.html">&lt;----- back</a><br><em>'"$version"'</em>
</body></html>' > /tmp/thriftcode/html-report/downstyle.txt

                              ################################Home  page################################
cat /tmp/thriftcode/html-report/upstyle.txt > index.html
cat /tmp/thriftcode/html-report/links_style.txt >> index.html 
cat /tmp/thriftcode/html-report/time.txt >> index.html
echo "<strong><em>CPU (proccesor) model name:</em></strong><em>  $(text_calculator /proc/cpuinfo 'model name' 13)</em>
<br><br>
<strong><em>VGA (video graphics accelerator):</em></strong><em>
$(text_calculator /tmp/thriftcode/html-report/pci.txt VGA 35)
</em><br><br>
<strong><em>kernel version : </em></strong>
$(cat /proc/version)<br><br>
<strong><em>operating system : </em></strong>
$(cat /proc/version_signature)
<br><br>" >> index.html
#Home page's table (ram, swap and hdd)...
total=$(df -h --total | grep 'total' | tail --bytes=45)
echo '<table>
<tr><th>
<strong><u>RAM memory info :</u></th>
<th><strong><u>Swap memory info :</u></th>
<th><strong><u>Hard disk info : </u></th></tr>
<tr><td><strong>Free : </strong>' > /tmp/thriftcode/html-report/index_table.txt
echo "$(expr $(text_calculator /proc/meminfo MemFree: 16 | head --bytes=9) / 1024) MB" >> /tmp/thriftcode/html-report/index_table.txt
echo '</td><td><strong>Free : </strong>' >> /tmp/thriftcode/html-report/index_table.txt
echo "$(expr $(text_calculator /proc/meminfo  SwapFree: 11 | head --bytes=13) / 1024) MB" >> /tmp/thriftcode/html-report/index_table.txt
echo '</td><td><strong>    Free space : </strong>' >> /tmp/thriftcode/html-report/index_table.txt
echo -e "$(echo $total | tail --bytes=8 | head --bytes=4)"'B (used '"$(echo $total | tail --bytes=4)"')' >> /tmp/thriftcode/html-report/index_table.txt
echo '</td></tr><tr><td><strong>Total : </strong>' >> /tmp/thriftcode/html-report/index_table.txt
echo "$(expr $(text_calculator /proc/meminfo  MemTotal: 16 | head --bytes=9) / 1024) MB" >> /tmp/thriftcode/html-report/index_table.txt
echo '</td><td><strong>Total : </strong>' >> /tmp/thriftcode/html-report/index_table.txt
echo "$(expr $(text_calculator /proc/meminfo  SwapTotal: 11 | head --bytes=13) / 1024) MB" >> /tmp/thriftcode/html-report/index_table.txt
echo '</td><td><strong>    Total space: </strong>' >> /tmp/thriftcode/html-report/index_table.txt
echo "$(echo $total | tail --bytes=20 | head --bytes=4 && echo -e B)" >> /tmp/thriftcode/html-report/index_table.txt
echo '</td></tr></table>' >> /tmp/thriftcode/html-report/index_table.txt
cat /tmp/thriftcode/html-report/index_table.txt >> index.html
#Crontab iframe
crontab -l > /tmp/thriftcode/html-report/crontab.txt
cron_counter=$(cat /tmp/thriftcode/html-report/crontab.txt | wc --bytes)
if [ $cron_counter -le 5 ]; then
    echo -e "Error : There are no cronjobs or I can't find them"'!'"\nTotal cronjobs : 0" >> /tmp/thriftcode/html-report/crontab.txt
fi
echo "<br><strong><em> Crontab jobs (scheduled tasks) : </em></strong><br>" >> index.html
echo '<iframe src=/tmp/thriftcode/html-report/crontab.txt width=1349 height=100 ></iframe><br>' >> index.html
#Links
echo "<br><a href='pci_bus.html'>PCI bus info</a>
<br><br>
<a href='hard_disk.html'>Filesystem info</a>
<br><br>
<a href='processes.html'>current processes</a>
<br><br>
<a href='temporary_files.html'>Temporary files (tmp)</a><br>" >> index.html
#End of homepage
echo '<br><em>'"$version"'</em>' >> index.html
echo '</body></html>' >> index.html

#SRC pages
#Hard disk
df -h > /tmp/thriftcode/html-report/hard_disk.txt
iframe_source '/tmp/thriftcode/html-report/hard_disk.txt' 'Filesystem info :' 'hard_disk.html'
#PCI Bus
lspci > /tmp/thriftcode/html-report/pci_bus.txt
iframe_source '/tmp/thriftcode/html-report/pci_bus.txt' 'PCI bus info :' 'pci_bus.html'
#Processes
ps > /tmp/thriftcode/html-report/processes.txt
iframe_source '/tmp/thriftcode/html-report/processes.txt' 'Current processes :' 'processes.html'
#Temporary files
ls /tmp > /tmp/thriftcode/html-report/temporary_files.txt
iframe_source '/tmp/thriftcode/html-report/temporary_files.txt' 'Temporary Files :' 'temporary_files.html'

firefox -new-window /tmp/thriftcode/html-report/index.html

exit
