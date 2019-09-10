APPNAME=huffman
APPMAIN=./src/main.cpp
TESTMAIN=ppr_tb_test_cli
###########################################################################
# Which compiler
CC=g++
FC=g77
###########################################################################
# Where to install
TARGET=./
###########################################################################
# Where are include files kept
LIBS=-lcppunit
INCLUDES=-I./src -I./test
###########################################################################
# Compile option
CFLAGS=-g -Wall -coverage

SRC:=$(filter-out $(APPMAIN),$(wildcard ./src/*.c))
TEST:=$(wildcard ./test/*.c)
OBJ:=$(SRC:.c=.o) $(TEST:.c=.o)

###########################################################################
# Control Script
all: clean compile report
clean:
    
	find ./ -name *.o -exec rm -v {} \;
	find ./ -name *.gcno -exec rm -v {} \;
	find ./ -name *.gcda -exec rm -v {} \;
	-rm $(APPNAME)
	-rm $(TESTMAIN)
	-rm *_result.xml
	-rm doxygen_*
	-rm -rf html
	-rm -rf latex
clean:	make makefile_blatt06 ;

###########################################################################
# Body
compile: $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(TESTMAIN) $(LIBS)

%.o : %.c
	$(CC) $(CFLAGS) $(LIBS) $(INCLUDES) -c $< -o $@
# ============================================================================
# Regeln
# ============================================================================

# ----------------------------------------------------------------------------
# Regel fuer das Vorbereiten von Splint
splint-setup :

	@for file in $(BUILD_DIR)/*.c; do \
		sed 's/#include <sys\\stat.h>/#include <sys\/stat.h>/g' "$$file" > $(TMP_MAIN); \
		mv $(TMP_MAIN) "$$file"; \
	done
	@echo


# ----------------------------------------------------------------------------
# Regel fuer das Vorbereiten der Tests
compile-setup : 

    # Testprogramm im build-Verzeichnis erzeugen...
	@gcc $(TESTS_DIR)/$(TEST).c $(SRC_GLOBAL_DIR)/$(LOGGING).c \
	             -o $(BUILD_DIR)/$(TEST).o \
	             -I$(SRC_GLOBAL_DIR) -DTESTBENCH;

    # wait_and_exit im build-Verzeichnis erzeugen
	@gcc $(SRC_GLOBAL_DIR)/$(CTRL).c -o $(BUILD_DIR)/$(CTRL).o \
	                                 -DFUNCTION_TEST;
                                     
# ----------------------------------------------------------------------------
# Regel zum Testen des aktuellen Programms
test: start \
      test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 test11 test12 \
      end
 
start:
	@echo -e "\f"; 
	@echo "+--------------------------------------------------------------+"
	@echo "| TEST $(LABEL)"
	@echo "+--------------------------------------------------------------+"
	@echo
    # Testdateien ins build-Verzeichnis kopieren
	-@cp ./$(TEST_DIR)/testfiles/* $(BUILD_DIR)/ 2> /dev/null


# Regeln fuer die einzelnen Testfaelle
test1 :
	@echo
	@echo ================================================================;
	@echo Testfall 1 : alle Parameter, ausser -h 
	@echo    - Aufruf         : huffman -c -o out.txt -l7 -v in.txt 
	@echo    - Soll-Verhalten : Korrekte Eingabe, Programmende mit Exitcode 0
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -o out.txt -l7 -v in.txt; \
            ./$(TEST).o -retval 0 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test2 :
	@echo
	@echo ================================================================;
	@echo Testfall 2 : zu wenig Parameter
	@echo    - Aufruf         : huffman   
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o ; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test3 :
	@echo
	@echo ================================================================;
	@echo Testfall 3 : -o Aufruf ohne Ausgabedatei
	@echo    - Aufruf         : huffman -c -o in.txt  
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -o in.txt; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);
    
test4 :
	@echo
	@echo ================================================================;
	@echo Testfall 4 : mit Ausgabedatei
	@echo    - Aufruf         : huffman -d -o out.txt in.txt  
	@echo    - Soll-Verhalten : Korrekte Eingabe, Programmende mit Exitcode 0
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -d -o out.txt in.txt; \
            ./$(TEST).o -retval 0 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test5 :
	@echo
	@echo ================================================================;
	@echo Testfall 5 : Unbekannte Option
	@echo    - Aufruf         : huffman -c -x in.txt  
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -x in.txt; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test6 :
	@echo
	@echo ================================================================;
	@echo Testfall 6 : Level bei Option -l fehlt
	@echo    - Aufruf         : huffman -c -l in.txt 
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -l in.txt; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test7 :
	@echo
	@echo ================================================================;
	@echo Testfall 7 : Ungueltiger Level, muss zwischen 1 und 9 sein
	@echo    - Aufruf         : huffman -c -l45 in.txt  
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
   
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -l45 in.txt; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test8 :
	@echo
	@echo ================================================================;
	@echo Testfall 8 : Namen von Ein- und Ausgabedatei sind gleich.
	@echo    - Aufruf         : huffman -c -o in.txt in.txt  
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -o in.txt in.txt; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test9 :
	@echo
	@echo ================================================================;
	@echo Testfall 9 : Weder -d noch -c angegeben.
	@echo    - Aufruf         : huffman in.txt  
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 2
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o in.txt; \
            ./$(TEST).o -retval 2 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test10 :
	@echo
	@echo ================================================================;
	@echo Testfall 10 : Eingabedatei existiert nicht.
	@echo    - Aufruf         : huffman -c not_exists.txt  
	@echo    - Soll-Verhalten : Fehlermeldung, Programmabbruch mit Fehlercode 3
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c not_exists.txt; \
            ./$(TEST).o -retval 3 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test11 :
	@echo
	@echo ================================================================;
	@echo Testfall 11 : Grosse Datei, -c, Laufzeitmessung
	@echo    - Aufruf         : huffman -c -v -o gross.hc gross.txt  
	@echo    - Soll-Verhalten : Laufzeitmessung, byteweises Kopieren
	@echo
    # Datei Prüfung einbauen.
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -c -v -o gross.hc gross.txt; \
            ./$(TEST).o -retval 0 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);

test12 :
	@echo
	@echo ================================================================;
	@echo Testfall 12 : Grosse Datei, -d, Laufzeitmessung
	@echo    - Aufruf         : huffman -d -v -o gross.hd gross.txt
	@echo    - Soll-Verhalten : Laufzeitmessung, bitweises Kopieren
	@echo
    
	-@cd $(BUILD_DIR) \
        && (./$(USER_SUBMISSION).o -d -v -o gross.hd gross.txt; \
            ./$(TEST).o -retval 0 $$?; ) &

	-@./$(BUILD_DIR)/$(CTRL).o -builddir $(BUILD_DIR) \
                             -app $(USER_SUBMISSION).o \
                             -timeout $(TIMEOUT);
report:
	./$(TESTMAIN)
	doxygen doxygen.conf src > /dev/null
	doxygen doxygen.conf > /dev/null
	gcovr -r . --html --html-details -o example-html-details.html
	cppcheck -v --enable=all --xml --xml-version=2 test/ppr_tb_test_cli.c 2> cppcheck-result.xml
	gcovr --xml --output=gcover_result.xml src/
	
	