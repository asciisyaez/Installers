wget https://raw.githubusercontent.com/asciisyaez/Installers/main/Scripts/audit_review.sh && sudo sh audit_review.sh >> "$(date +'%m_%d_%Y')-$HOSTNAME-audit.log" && echo "$HOSTNAME-Audit Report-$(date +'%m/%d/%Y')" | mailx -vvv -a "$(date +'%m_%d_%Y')-$HOSTNAME-audit.log" -r fn_osreport@sea.com -s "$HOSTNAME_Audit Review" -S smtp="smtp.cit.seagroup.com" corp-it-system@sea.com && rm -rf audit_review.sh*