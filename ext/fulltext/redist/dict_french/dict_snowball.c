/* 
 * example of Snowball dictionary
 * http://snowball.tartarus.org/ 
 * Teodor Sigaev <teodor@sigaev.ru>
 */
#include <stdlib.h>
#include <string.h>

#include "postgres.h"

#include "dict.h"
#include "common.h"
#include "snowball/header.h"
#include "subinclude.h"

typedef struct {
	struct SN_env *z;
	StopList	stoplist;
	int	(*stem)(struct SN_env * z);
} DictSnowball;


PG_FUNCTION_INFO_V1(dinit_french);
Datum dinit_french(PG_FUNCTION_ARGS);

Datum 
dinit_french(PG_FUNCTION_ARGS) {
	DictSnowball	*d = (DictSnowball*)malloc( sizeof(DictSnowball) );

	if ( !d )
		ereport(ERROR,
				(errcode(ERRCODE_OUT_OF_MEMORY),
				 errmsg("out of memory")));
	memset(d,0,sizeof(DictSnowball));
	d->stoplist.wordop=lowerstr;
		
	if ( !PG_ARGISNULL(0) && PG_GETARG_POINTER(0)!=NULL ) {
		text       *in = PG_GETARG_TEXT_P(0);
		readstoplist(in, &(d->stoplist));
		sortstoplist(&(d->stoplist));
		PG_FREE_IF_COPY(in, 0);
	}

	d->z = french_create_env();
	if (!d->z) {
		freestoplist(&(d->stoplist));
		ereport(ERROR,
				(errcode(ERRCODE_OUT_OF_MEMORY),
				 errmsg("out of memory")));
	}
	d->stem=french_stem;

	PG_RETURN_POINTER(d);
}


