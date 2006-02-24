#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <libstree.h>


int redirect_stderr () {
  return dup2(fileno(stdout), fileno(stderr));
}
 
void restore_stderr (int old) {
  if (old != -1) dup2(old, fileno(stderr));     
}

#define SV2TREE(S) (LST_STree *)SvIV(SvRV(S))


MODULE = Tree::Suffix  PACKAGE = Tree::Suffix

SV *
new (class, ...)
    char *class
  PROTOTYPE: $;@
  PREINIT:
    LST_STree *tree;
    LST_String *string;
    STRLEN len;
    char *str;
    IV i;
  CODE:
    tree = lst_stree_new(NULL);
    for (i = 1; i < items; i++) {
      str = (char *)SvPV(ST(i), len);
      string = lst_string_new(str, 1, len);
      lst_stree_add_string(tree, string);
    }
    RETVAL = sv_setref_pv(newSViv(0), class, (void *)tree);
    OUTPUT:
      RETVAL


void
DESTROY (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    lst_stree_free(tree);


void
allow_duplicates (self, flag=1)
    SV *self
    IV flag
  PROTOTYPE: $$
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    lst_stree_allow_duplicates(tree, flag);


IV
insert (self, ...)
    SV *self
  PROTOTYPE: $@
  PREINIT:
    LST_STree *tree;
    LST_String *string;
    STRLEN len;
    char *str;
    IV i;
  CODE:
    tree = SV2TREE(self);
    for (i = 1; i < items; i++) {
      str = (char *)SvPV(ST(i), len);
      string = lst_string_new(str, 1, len);
      lst_stree_add_string(tree, string);
    }
    /* lst_stree_add_string doesn't indicate success, so can't determine
     * count
     */
    XSRETURN_IV(items-1);


IV
strings (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    RETVAL = tree->num_strings;
  OUTPUT:
    RETVAL


IV
nodes (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    RETVAL = tree->root_node->num_kids;
  OUTPUT:
    RETVAL


void
clear (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    lst_stree_clear(tree);
    lst_stree_init(tree);


void
dump (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
    IV fn;
  CODE:
    tree = SV2TREE(self);
    fn = redirect_stderr();    
    /* Redirect from stderr to stdout */
    lst_debug_print_tree(tree);
    restore_stderr(fn);


IV
remove (self, ...)
    SV *self
  PROTOTYPE: $@
  PREINIT:
    LST_STree *tree;
    LST_StringHash *hash;
    LST_StringHashItem *hi;
    LST_String *string;
    STRLEN len;
    char *str;
    IV i, j, k, done = 0;
  CODE:
    tree = SV2TREE(self);
    for (i = 1; i < items; i++) {
      str = (char *)SvPV(ST(i), len);
      string = lst_string_new(str, 1, len);
      /* Check each hash bucket for the string.  Is there an easier way? */
      for (j = 0; j < LST_STRING_HASH_SIZE; j++) {
        hash = &tree->string_hash[j];
        for (hi = hash->lh_first; hi; hi = hi->items.le_next) {
          if (lst_string_get_length(hi->string) != len)
            continue;
          for (k = 0; k < len && lst_string_eq(string, k, hi->string, k); k++);
          if (k == len) {
            lst_stree_remove_string(tree, hi->string);
            done++;
            goto next_item;
          }
        }
      }
      next_item: 1;
    }
    XSRETURN_IV(done);


void
_algorithm_longest_substrings (self, min_len=0, max_len=0)
    SV *self
    IV min_len
    IV max_len
  ALIAS:
    lcs = 1
    lrs = 2
  PROTOTYPE: $;$$
  PREINIT:
    LST_STree *tree;
    LST_StringSet *res;
    LST_String *str;
  PPCODE:
    tree = SV2TREE(self);
    if (ix == 1) {
      res = lst_alg_longest_common_substring(tree, min_len, max_len);
      /* this allows lcs to be called again even if the tree hasn't changed */
      tree->needs_visitor_update = 1;
    }
    else
      res = lst_alg_longest_repeated_substring(tree, min_len, max_len);
    if (res) {
      EXTEND(SP, res->size);
      for (str = res->members.lh_first; str; str = str->set.le_next)
        PUSHs(sv_2mortal(newSVpv((char *)lst_string_print(str), 0)));
      lst_stringset_free(res);
    }
