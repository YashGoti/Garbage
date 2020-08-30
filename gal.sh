#!/bin/bash

help(){
	echo -e "[Usage]:"
  	echo -e "\t$ ~/gal URL/DOMAIN"
	echo -e "\t-h\thelp"
}

validateURL(){
	if [[ -z $1 ]]; then 
		:
	else
		case $1 in
			http://*      ) if [[ $1 == */ ]]; then echo $1; else echo $1/; fi; ;;
			https://*     ) if [[ $1 == */ ]]; then echo $1; else echo $1/; fi; ;;
			*             ) if [[ $1 == *.html ]] || [[ $1 == *.js ]]; then echo https://$1; else echo https://$1/; fi; ;;
			*.html        ) if [[ $1 == http://* ]] || [[ $1 == https://* ]]; then echo $1; else echo https://$1; fi; ;;
			*.js          ) if [[ $1 == http://* ]] || [[ $1 == https://* ]]; then echo $1; else echo https://$1; fi; ;;
		esac
	fi
}

getContent(){
	curl -siL $1 > tmp.txt
}

find(){
	cat tmp.txt | grep -iohE '<a [^>]+>' | grep -iohE 'href="[^\"]+"' | cut -d '=' -f2 | cut -d '"' -f2 | cut -d "'" -f2 | grep -v '^#' | grep -v '^/$' | grep -v '^//$' | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | grep -iohE '(?<=href=")[^"]*(?=")' | grep -iohE 'href="[^\"]+"' | cut -d '=' -f2 | cut -d '"' -f2 | cut -d "'" -f2 | grep -v '^#' | grep -v '^/$' | grep -v '^//$' | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | grep -iohE '<script [^>]+>' | grep -iohE 'src="[^\"]+"' | cut -d '=' -f2 | cut -d '"' -f2 | cut -d "'" -f2 | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | grep -iohE '(?<=src=")[^"]*(?=")' | grep -iohE 'src="[^\"]+"' | cut -d '=' -f2 | cut -d '"' -f2 | cut -d "'" -f2 | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | grep -iohE '(http|https|ftp|sftp|file)?://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]' | cut -d '"' -f1 | cut -d "'" -f2 | grep -v '^#' | grep -v '^/$' | grep -v '^//$' | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | grep -oihE '(http|https|ftp|sftp|file)?://[a-zA-Z0-9./?=_%:-]*' | cut -d '"' -f1 | cut -d "'" -f2 | grep -v '^#' | grep -v '^/$' | grep -v '^//$' | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | grep -oihE '(http|https|ftp|sftp|file)?://[^ ]+' | cut -d '"' -f1 | cut -d "'" -f2 | grep -v '^#' | grep -v '^/$' | grep -v '^//$' | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt &
	cat tmp.txt | sed -n -E "s/.*(href|src|link|file|url|path)[=:]['\"]?([^'\">]+).*/\2/p" | grep -v '^#' | grep -v '^/$' | grep -v '^//$' | grep -ivE '^#|^javascript:' | sed -e 's/^\/\//\//g' | sed -e 's,^\/,'"$1"',g' | sort -u >> _tmp.txt
	cat _tmp.txt | sort -u | grep .
	rm -rf tmp.txt _tmp.txt
}

if [[ -z $1 ]]; then
	help
else
	getContent $(validateURL $1) ; find $(validateURL $1)
fi
