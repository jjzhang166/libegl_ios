# !/bin/sh

#
#	Usage: check.sh -h
#	Author: David Andreoletti http://davidandreoletti.com
#

INCLUDE_DIRS=""
EXCLUDE_DIRS=""
INCLUDE_FEXTS="h cpp c"
EXCLUDE_FILES=""

# Apply cpplint on directories
# $1 Include directories. Space separated
# $2 Exclude directories. Space separated
# $3 Include file extensions. Space separated
# $4 Exclude files. Space separated
function lintFiles() {
    local iDirs="$1"
    local eDirs="$2"
    local ifExts="$3"
    local efs="$4"
	
	local iDArg=""
	local eDArg=""
	local ifExtArg=""
	local eFArg=""
		
	IFS_BAK=$IFS
	IFS=" "
	
    for d in ${iDirs};
    do
		iDArg="${iDArg} ${d}"
    done;
	
	local isFirstLoop=0		
    for fe in ${ifExts};
    do
		[ ${isFirstLoop} -eq 1 ] && ifExtArg="${ifExtArg} -o " || isFirstLoop=1
		ifExtArg="${ifExtArg} -name *.${fe}"
    done;
	
	isFirstLoop=0
    for d in ${eDirs};
    do
		[ ${isFirstLoop} -eq 1 ] && eDArg="${eDArg} -o " || isFirstLoop=1
		eDArg="${eDArg} -path ${d}"
    done;
	
	isFirstLoop=0
    for f in ${efs};
    do
		[ ${isFirstLoop} -eq 1 ] && eFArg="${eFArg} -o " || isFirstLoop=1
		eFArg="${eFArg} -path ${f}"
    done;
		
	local pre=""
	local post=""
	
	[ -z "${iDirs}" ] && iDArg=""
	[ -z "${ifExts}" ] && ifExtArg="" || ifExtArg="( ${ifExtArg} )"
	[ -z "${eDirs}" ] && eDArg="" || eDArg="( -type d ( ${eDArg} ) -prune )"
	[ -z "${efs}" ] && eFArg="" || 	eFArg="( -type f ( ${eFArg} ) -prune )"
	
	[ -n "${efs}" ] && eFArg="${eFArg} -o"
	[ -n "${eDirs}" ] && eDArg="${eDArg} -o"
	
	IFS=$IFS_BAK
    find ${iDArg} ${eDArg} ${eFArg} $ifExtArg -exec python cpplint.py {} \; 
}

function usage() {
    echo "Usage:"
    echo "-i            Include directories."
	echo "                  Valid values: Space seprarated absolute path directories"
	echo "                  Default: ${INCLUDE_DIRS}"
    echo "-e            Exclude directories. Space seprarated absolute path directories"
	echo "                  Valid values: Space seprarated directories"
    echo "                  Default: ${EXCLUDE_DIRS}"
    echo "-t            File extensions to process in includes directories."
    echo "                  Valid values: Space separated extension."
    echo "                  Default: ${INCLUDE_FEXTS}"
    echo "-x            Exclude files."
    echo "                  Valid values: Space separated absolute path files."
    echo "                  Default: ${EXCLUDE_FILES}"
    echo "-h            Help"
}

# Show summary
# $1 Include directories
# $2 Include directories
function summary() {
	echo "Include directories:       ${INCLUDE_DIRS}"
	echo "Exclude directories:       ${EXCLUDE_DIRS}"
	echo "Include file extensions:   ${INCLUDE_FEXTS}"
	echo "Exclude files:             ${EXCLUDE_FILES}"
}

#######################################################################################
echo "================================================================================"

while [ "$1" != "" ]; do
    case $1 in
        -f )                    shift
                                while [ "$1" != "" ]; do
                                    case $1 in
                                        -i | -f | -e | -x ) break
                                        ;;
										* ) INCLUDE_FEXTS="${INCLUDE_FEXTS} $1"
											shift
										;;
                                    esac
                                done
                                ;;
        -i )                    shift
                                while [ "$1" != "" ]; do
                                    case $1 in
                                        -i | -f | -e | -x) break
                                        ;;
										* ) INCLUDE_DIRS="${INCLUDE_DIRS} $1"
											shift
										;;
                                    esac
                                done
                                ;;
        -e )                    shift
						        while [ "$1" != "" ]; do
						            case $1 in
						                -i | -f | -e | -x) break
						                ;;
										* ) EXCLUDE_DIRS="${EXCLUDE_DIRS} $1"
											shift
										;;
						            esac
						        done
                                ;;
        -x )                    shift
						        while [ "$1" != "" ]; do
						            case $1 in
						                -i | -f | -e | -x) break
						                ;;
										* ) EXCLUDE_FILES="${EXCLUDE_FILES} $1"
											shift
										;;
						            esac
						        done
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
done

[ -z "${INCLUDE_DIRS}" ] && echo "Error: No include directories specified" && exit;

summary

lintFiles "${INCLUDE_DIRS}" "${EXCLUDE_DIRS}" "${INCLUDE_FEXTS}" "${EXCLUDE_FILES}"
