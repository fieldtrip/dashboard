tokb () {
 ((g=(${1}+500)/1000))
 printf "%dkb\n" $g
}
tomb () {
 ((g=(${1}+500000)/1000000))
 printf "%dmb\n" $g
}
togb () {
 ((g=(${1}+500000000)/1000000000))
 printf "%dgb\n" $g
}
