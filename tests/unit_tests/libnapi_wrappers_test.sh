#!/bin/bash

# force indendation settings
# vim: ts=4 shiftwidth=4 expandtab

########################################################################
########################################################################
########################################################################

#  Copyright (C) 2017 Tomasz Wisniewski aka
#       DAGON <tomasz.wisni3wski@gmail.com>
#
#  http://github.com/dagon666
#  http://pcarduino.blogspot.co.uk
#
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

########################################################################
########################################################################
########################################################################

# module dependencies

# fakes/mocks

# module under test
. ../../libs/libnapi_wrappers.sh

setUp() {
    export SCPMOCKER_DB_PATH="$(mktemp -d -p "$SHUNIT_TMPDIR")"
    export MOCK_BIN="$(mktemp -d -p "$SHUNIT_TMPDIR")"
    export PATH_ORIG="$PATH"
    export PATH="${MOCK_BIN}:${PATH}"
}

tearDown() {
    export PATH="${PATH_ORIG}"
}

test_wrappers_ensureNumeric_SO_convertsStringToNumerics() {
    for i in {1..16}; do
        assertEquals "checking $i" \
            "$i" "$(wrappers_ensureNumeric_SO "$i")"
    done
}

test_wrappers_ensureNumeric_SO_convertsStringInputToZero() {
    for i in {1..16}; do
        local input="string${i}"
        assertEquals "checking $input" \
            "0" "$(wrappers_ensureNumeric_SO "$input")"
    done
}

test_wrappers_countLines_SO_normalInput() {
	local result=0
	result=$(echo -e "line1\nline2\nline3" | wrappers_countLines_SO)
	assertEquals "checking count_lines output" \
        3 "$result"
}

test_wrappers_lcase_SO_normalInput() {
	local result=0;
	result=$(echo -e "UPPER_CASE_STR" | wrappers_lcase_SO)
	assertEquals "checking lcase output" \
        "upper_case_str" "$result"
}

test_wrappers_stripNewLine_SO_normalInput() {
	local result=0;
	result=$(echo -e "line1\r\nline2\nline3" | \
        wrappers_stripNewLine_SO | \
        wrappers_countLines_SO)

	assertEquals "checking strip_newline output" \
        0 "$result"
}

test_wrappers_stripNewLine_SO_noNewLinesInput() {
	local result=0;
	result=$(echo -e "no new lines" | \
        wrappers_stripNewLine_SO | \
        wrappers_countLines_SO)

	assertEquals "checking strip_newline output" \
        0 "$result"
}

test_wrappers_getExt_SO() {
    local fn='file with spaces.abc.txt'
    local ext=$(wrappers_getExt_SO "$fn")
    assertEquals 'verify extension' \
        'txt' "$ext"
}

test_wrappers_stripExt_SO() {
    local fn='file with spaces.abc.txt'
    local filename=$(wrappers_stripExt_SO "$fn")
    assertEquals 'verify extension' \
        'file with spaces.abc' "$filename"
}

test_wrappers_floatComparisonOperations() {
	local status=0

	wrappers_floatLt "2.0" "3.0"
	assertEquals "lt 1" 0 "$?"

	wrappers_floatLt "3.0" "3.0"
	assertNotEquals "lt 2" 0 "$?"

	wrappers_floatLt "2.5" "3.123"
	assertEquals "lt 3" 0 "$?"

	wrappers_floatGt "3.0" "3.0"
	assertNotEquals "gt 1" 0 "$?"

	wrappers_floatGt "4.0" "3.0"
	assertEquals "gt 2" 0 "$?"

	wrappers_floatLe "3.0" "3.0"
	assertEquals "le 1" 0 "$?"

	wrappers_floatLe "3.1" "3.0"
	assertNotEquals "le 2" 0 "$?"

	wrappers_floatGe "3.0" "3.0"
	assertEquals "ge 1" 0 "$?"

	wrappers_floatGe "4.0" "3.0"
	assertEquals "ge 2" 0 "$?"

	wrappers_floatGe "2.0" "3.0"
	assertNotEquals "ge 2" 0 "$?"

	wrappers_floatEq "4.0" "3.0"
	assertNotEquals "eq 1" 0 "$?"

	wrappers_floatEq "3.0" "3.0"
	assertEquals "eq 1" 0 "$?"
}

test_floatDivOperations() {
    local result=

    result=$(wrappers_floatDiv 123 0)
    assertNotEquals "div by zero - return value" \
        0 "$?"

    result=$(wrappers_floatDiv 123 1)
    assertEquals "div by 1 - return value" \
        0 "$?"
    assertEquals "div by 1 - result" \
        123 "$result"

    result=$(wrappers_floatDiv 120 4)
    assertEquals "div by 4 - return value" \
        0 "$?"
    assertEquals "div by 4 - result" \
        30 "$result"

    result=$(wrappers_floatDiv 1 4)
    assertEquals "div 1 by 4 - return value" \
        0 "$?"
    assertEquals "div 1 by 4 - result" \
        "0.25" "$result"
}

test_floatMulOperations() {
    local result=

    result=$(wrappers_floatMul 123 0)
    assertEquals "mul by 0 - return value" \
        0 "$?"
    assertEquals "mul by 0 - result" \
        0 "$result"

    result=$(wrappers_floatMul 10 10)
    assertEquals "mul by 10 - return value" \
        0 "$?"
    assertEquals "mul by 10 - result" \
        100 "$result"

    result=$(wrappers_floatMul 1.5 10)
    assertEquals "mul by 1.5 - return value" \
        0 "$?"
    assertEquals "mul by 1.5 - result" \
        15 "$result"

    result=$(wrappers_floatMul 0.25 4)
    assertEquals "mul by 0.25 - return value" \
        0 "$?"
    assertEquals "mul by 0.25 - result" \
        1 "$result"
}

test_wrappers_getSystem_returnsLowerCaseSystemName() {
    scpmocker -c uname program -s "Linux"
    scpmocker -c uname program -s "Darwin"

    ln -sf "$(which scpmocker)" "${MOCK_BIN}/uname"

    assertEquals "check system for linux" \
        "linux" "$(wrappers_getSystem_SO)"

    assertEquals "check system for darwin" \
        "darwin" "$(wrappers_getSystem_SO)"
}

test_wrappers_isSystemDarwin_returnsTrueForDarwin() {
    scpmocker -c uname program -s "Darwin"
    ln -sf "$(which scpmocker)" "${MOCK_BIN}/uname"

    assertTrue "check for rv for Darwin" \
        wrappers_isSystemDarwin
}

test_wrappers_getCores_returnsCoresFromProcOnLinux() {
    scpmocker -c sysctl program -s "123"
    scpmocker -c uname program -s "Linux"

    ln -sf "$(which scpmocker)" "${MOCK_BIN}/sysctl"
    ln -sf "$(which scpmocker)" "${MOCK_BIN}/uname"

    wrappers_getCores_SO >/dev/null

    assertEquals "check sysctl mock call count" \
        0 "$(scpmocker -c sysctl status -C)"
}

test_wrappers_getCores_returnsCoresFromSysctlOnDarwin() {
    scpmocker -c sysctl program -s "123"
    scpmocker -c uname program -s "Darwin"

    ln -sf "$(which scpmocker)" "${MOCK_BIN}/uname"
    ln -sf "$(which scpmocker)" "${MOCK_BIN}/sysctl"

    local cores=$(wrappers_getCores_SO)

    assertEquals "check cores value" \
        123 "$cores"

    assertEquals "check sysctl mock call count" \
        1 "$(scpmocker -c sysctl status -C)"
}

# shunit call
. shunit2
