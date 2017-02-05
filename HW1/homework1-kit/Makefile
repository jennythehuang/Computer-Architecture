all: fibtimes2 recurse HoopStats

kit: homework1-grading.tgz

homework1-grading.tgz: hw1grade.py grading_tests HW1_GRADING_VERSION Autograder_rubric.pdf
	./hw1grade.py CLEAN
	tar cvzf $@ $^

clean:
	rm -f fibtimes2 recurse HoopStats
	./hw1grade.py CLEAN

fibtimes2: fibtimes2.c
	g++ -g -o $@ $<

recurse: recurse.c
	g++ -g -o $@ $<

HoopStats: HoopStats.c
	g++ -g -o $@ $<
