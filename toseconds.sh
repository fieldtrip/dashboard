toseconds() {
  for v in "${@:-$(</dev/stdin)}"
  do
    echo $v | awk --field-separator : \
      '/..:..:../ {printf "%u\n", $1*3600+$2*60+$3}'
  done
}

