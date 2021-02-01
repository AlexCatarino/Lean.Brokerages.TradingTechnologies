#/bin/bash
########################################################
# Parameters
declare -r filepath=$(pwd $(dirname "${0}"))/TT-FIX44.xml
declare -r fix_version="FIX44"

# Other variables
declare -r start_directory=$(pwd $(dirname "${0}"))
declare -r repo_directory="${start_directory}/quickfixn"
declare -r project_directory="${start_directory}/quickfixn/Messages/${fix_version}"

########################################################
echo "=== Checking requirements"
which ruby || exit 1
which gem || exit 1
which git || exit 1
echo -n "Checking Ruby gem nokogiri: "; gem list -i nokogiri || exit 1

########################################################
echo -e "\n=== Checking quickfixn repo"
if [ -d "${repo_directory}" ]; then
	cd "${repo_directory}"
	git reset './*' || exit 32
	git checkout './*' || exit 33
	git clean -xfd || exit 34
	git pull
else
	git clone --no-tags --single-branch --branch master --depth 1 git@github.com:connamara/quickfixn.git "${repo_directory}" || exit 31
fi
echo "Done."

########################################################
echo -e "\n=== Clearing project directory"
find "${project_directory}" -type f -name '*.cs' -delete

########################################################
echo -e "\n=== Copying FIX Specification"
cp "${filepath}" "${repo_directory}/spec/fix/${fix_version}.xml" || exit 5

########################################################
echo -e "\n=== Running generator"
ruby "${repo_directory}/generator/generate.rb" || exit 6

########################################################
echo -e "\n=== Building Release project"
sed -i 's/<TargetFrameworks>.*<\/TargetFrameworks>/<TargetFrameworks>net462<\/TargetFrameworks>/g' "${project_directory}/QuickFix.${fix_version}.csproj" || exit 71
sed -i 's/<TargetFrameworks>.*<\/TargetFrameworks>/<TargetFrameworks>net462<\/TargetFrameworks>/g' "${repo_directory}/QuickFIXn/QuickFix.csproj" || exit 71

########################################################
echo "Completed"