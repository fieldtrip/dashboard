round () {
  awk -- '
    BEGIN {
      for (i = 1; i < ARGC; i++)
        printf "%.0f\n", ARGV[i]+0.001
    }' "$@"
}
