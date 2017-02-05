#!/usr/bin/python

# Auto Tester for Duke CS/ECE 250, Homework 1, Spring 2017
# By Tyler Bletsch (Tyler.Bletsch@duke.edu)

import sys,os,re,platform
from itertools import izip_longest

def hoopstat_diff(file1, file2, outfile):
    fp1 = open(file1,"r")
    fp2 = open(file2,"r")
    out = open(outfile,"w")
    n=0
    retval = 0
    def line_match(line1, line2):
        if line1==line2: 
            return True
        m1 = re.match(r"(\w+)\s+([.\d]+)$", line1)
        if not m1: return False
        m2 = re.match(r"(\w+)\s+([.\d]+)$", line2)
        if not m2: return False
        k1 = m1.group(1)
        v1 = float(m1.group(2))
        k2 = m2.group(1)
        v2 = float(m2.group(2))
        if k1 != k2 or abs(v1-v2)>0.0001:
            return False
        return True
    for line1,line2 in izip_longest(fp1,fp2, fillvalue=""):
        line1 = line1.rstrip()
        line2 = line2.rstrip()
        n += 1
        if not line_match(line1, line2):
            out.write("< %s\n> %s\n" % (line1,line2))
            retval = 1
    fp1.close()
    fp2.close()
    out.close()
    return retval
    
suite_names = ['fibtimes2', 'recurse', 'HoopStats' ]
suites = {
    "fibtimes2": [
        { "desc": "n = 1", "args": ['1'] },
        { "desc": "n = 2", "args": ['2'] },
        { "desc": "n = 3", "args": ['3'] },
        { "desc": "n = 4", "args": ['4'] },
        { "desc": "n = 5", "args": ['5'] },
    ],
    "recurse": [
        { "desc": "n = 0", "args": ['0'] },
        { "desc": "n = 1", "args": ['1'] },
        { "desc": "n = 2", "args": ['2'] },
        { "desc": "n = 3", "args": ['3'] },
    ],
    "HoopStats": [
        { "desc": "One name in file",              "args": ['tests/HoopStats_input_0.txt'], 'diff': hoopstat_diff },
        { "desc": "Two names in file",             "args": ['tests/HoopStats_input_1.txt'], 'diff': hoopstat_diff },
        { "desc": "Three names in file",           "args": ['tests/HoopStats_input_2.txt'], 'diff': hoopstat_diff },
        { "desc": "Four names in file",            "args": ['tests/HoopStats_input_3.txt'], 'diff': hoopstat_diff },
        { "desc": "Don't print names after DONE",  "args": ['tests/HoopStats_input_4.txt'], 'diff': hoopstat_diff },
    ]
}

if len(sys.argv)<=1:
    print "Auto Tester for Duke CS/ECE 250, Homework 1, Spring 2017"
    print ""
    print "Usage:"
    print "  %s <suite>" % sys.argv[0]
    print ""
    print "Where <suite> is one of:"
    print "  %-15s: Run all program tests" % ("ALL",)
    print "  %-15s: Remove all the test output produced by this tool in tests/" % ("CLEAN",)
    for suite_name in suite_names:
        print "  %-15s: Run tests for %s" % (suite_name,suite_name)
    sys.exit(1)

def get_expected_output_filename(suite_name, test_num):
    return "tests/%s_expected_%d.txt" % (suite_name, test_num)
    
def get_actual_output_filename(suite_name, test_num):
    return "tests/%s_actual_%d.txt" % (suite_name, test_num)
    
def get_diff_filename(suite_name, test_num):
    return "tests/%s_diff_%d.txt" % (suite_name, test_num)

def clean():
    my_system("rm -f tests/*_actual_*.txt tests/*_diff_*.txt", verbose=True)
    
def my_system(command, verbose=False):
    if verbose: print "\033[36m%s\033[m" % command
    r = os.system(command)
    if platform.system()[-1] == 'x':
        return r>>8 # platforms ending in 'x' are probably Linux/Unix, and they put exit status in the high byte
    else:
        return r # Windows platforms just return exit status directly
    
def run_test_suite(suite_name):
    suite = suites[suite_name]
    if not os.path.isfile(suite_name):
        print("\033[91m%s: Not found. Did you forget to compile your program?\033[m" % suite_name)
        return
    for test_num,test in enumerate(suite):
        desc = test['desc']
        args = test['args']
        expected_output_filename = get_expected_output_filename(suite_name, test_num)
        actual_output_filename = get_actual_output_filename(suite_name, test_num)
        diff_filename = get_diff_filename(suite_name, test_num)
        
        is_pass = True
        reason = ''
        
        command = "timeout 10s ./%s %s > %s" % (suite_name, " ".join(args), actual_output_filename)
        r = my_system(command)
        if r != 0:
            is_pass = False
            reason += "Exit status is non-zero. "
	    if r == 124:
		reason += "Killed due to a timeout, infinite loop in the program? "
            
        if 'diff' in test:
            special_diff_func = test['diff']
            r = special_diff_func(expected_output_filename, actual_output_filename, diff_filename)
        else:
            command = "diff -bwB %s %s > %s" % (expected_output_filename, actual_output_filename, diff_filename)
            r = my_system(command)
        if r != 0 and is_pass == True:
            is_pass = False
            reason += "Output differs from expected (see diff for details). "

        command = "timeout 10s valgrind -q --error-exitcode=88 --undef-value-errors=no --show-reachable=yes --leak-check=full ./%s %s > /dev/null" % (suite_name, " ".join(args))
        r = my_system(command)
        if r == 88:
            is_pass = False
            reason += "Valgrind detected memory leak. "
	elif r == 124 and is_pass == True:
	    is_pass = False
	    reason += "Killed due to a timeout, infinite loop in the program? "
        if is_pass: result_string = "\033[32;7mpass\033[m"
        else:       result_string = "\033[41mFAIL\033[0;31m %s\033[m" % reason
        print "%10s test #%2d (%-30s): %s" % (suite_name, test_num, desc, result_string)

requested_suite_name = sys.argv[1]
if requested_suite_name == "ALL":
    for suite_name in suite_names:
        run_test_suite(suite_name)
elif requested_suite_name == "CLEAN":
    clean()
elif requested_suite_name in suite_names:
    run_test_suite(requested_suite_name)
else:
    print "%s: No such test suite" % (requested_suite_name)
