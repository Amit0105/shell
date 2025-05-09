curl -s https://www.amfiindia.com/spages/NAVAll.txt -o NAVAll.txt

header_line=$(grep -m1 '^Scheme Code;' NAVAll.txt)

# Determine the column numbers for Scheme Name and Net Asset Value
IFS=';' read -ra headers <<< "$header_line"
for i in "${!headers[@]}"; do
  if [[ "${headers[$i]}" == "Scheme Name" ]]; then
    scheme_name_col=$((i + 1))
  elif [[ "${headers[$i]}" == "Net Asset Value" ]]; then
    nav_col=$((i + 1))
  fi
done

if [[ -z "$scheme_name_col" || -z "$nav_col" ]]; then
  echo "Required columns not found in the header."
  exit 1
fi

awk -F';' -v sn_col="$scheme_name_col" -v nav_col="$nav_col" '
  NR > 1 && NF >= nav_col {
    printf("{\"Scheme Name\": \"%s\", \"Net Asset Value\": \"%s\"}\n", $sn_col, $nav_col)
  }
' NAVAll.txt > scheme_nav.json

echo "Extraction complete. Output saved to scheme_nav.json"
