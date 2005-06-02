subdir = contrib/dict_french
top_builddir = ../..
include $(top_builddir)/src/Makefile.global

MODULE_big = dict_french
OBJS =  french_stem.o dict_snowball.o
DATA_built = dict_french.sql
DOCS = README.french
PG_CPPFLAGS = -I../tsearch2/snowball -I../tsearch2
SHLIB_LINK = ../tsearch2/libtsearch2.a

include $(top_srcdir)/contrib/contrib-global.mk
