#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <libstree.h>


int
redirect_stderr () {
  return dup2(fileno(stdout), fileno(stderr));
}
 
void
restore_stderr (int old) {
  if (old != -1) dup2(old, fileno(stderr));     
}

LST_Node *
follow_string (LST_STree *tree, LST_String *string) {
  LST_Node *node = tree->root_node;
  LST_Edge *edge = NULL;
  u_int todo = 0, done = 0, len, common;
  todo = string->num_items;
  while (todo > 0) {
    for (edge = node->kids.lh_first; edge; edge = edge->siblings.le_next)
      if (lst_string_eq(edge->range.string, edge->range.start_index,
                        string, done))
        break;
    if (! edge)
      break;
    len = lst_edge_get_length(edge);
    common = lst_string_items_common(edge->range.string,
                                     edge->range.start_index, string, done,
                                     len);
    done += common;
    todo -= common;
    node = edge->dst_node;
  }
  return (done < string->num_items - 1) ? NULL : node;
}

#define SV2TREE(S) (LST_STree *)SvIV(SvRV(S))


MODULE = Tree::Suffix  PACKAGE = Tree::Suffix


SV *
new (class, ...)
    char *class
  PROTOTYPE: $;@
  PREINIT:
    LST_STree *tree;
    IV i;
    STRLEN len;
    char *string;
  CODE:
    tree = lst_stree_new(NULL);
    if (! tree)
      XSRETURN_UNDEF;
    for (i = 1; i < items; i++) {
      if (! SvOK(ST(i)))
        continue;
      string = SvPV(ST(i), len);
      lst_stree_add_string(tree, lst_string_new(string, 1, len));
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


IV
allow_duplicates (self, flag=&PL_sv_yes)
    SV *self
    SV *flag
  PROTOTYPE: $;$
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    if (items == 2)
      lst_stree_allow_duplicates(tree, SvTRUE(flag));
    RETVAL = tree->allow_duplicates;
  OUTPUT:
    RETVAL


IV
insert (self, ...)
    SV *self
  PROTOTYPE: $@
  PREINIT:
    LST_STree *tree;
    STRLEN len;
    char *string;
    IV i, pre;
  CODE:
    if (items == 1)
      XSRETURN_IV(0);
    tree = SV2TREE(self);
    pre = tree->num_strings;
    for (i = 1; i < items; i++) {
      if (! SvOK(ST(i)))
        continue;
      string = SvPV(ST(i), len);
      lst_stree_add_string(tree, lst_string_new(string, 1, len));
    }
    XSRETURN_IV(tree->num_strings - pre);


void
strings (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
    LST_StringHash *hash;
    LST_StringHashItem *hi;
    IV i;
  PPCODE:
    tree = SV2TREE(self);
    if (GIMME_V != G_ARRAY)
      XSRETURN_IV(tree->num_strings);
    EXTEND(SP, tree->num_strings);
    for (i = 0; i < LST_STRING_HASH_SIZE; i++) {
      hash = &tree->string_hash[i];
      for (hi = hash->lh_first; hi; hi = hi->items.le_next)
        PUSHs(sv_2mortal(newSViv(hi->index)));
    }


IV
nodes (self)
    SV *self
  PROTOTYPE: $
  PREINIT:
    LST_STree *tree;
  CODE:
    tree = SV2TREE(self);
    XSRETURN_IV(tree->root_node->num_kids);


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
    /* Redirect from stderr to stdout */
    fn = redirect_stderr();    
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
    LST_String *str;
    STRLEN len;
    char *string;
    IV i, j, k, done = 0;
  CODE:
    tree = SV2TREE(self);
    for (i = 1; i < items; i++) {
      if (! SvOK(ST(i)))
        continue;
      string = SvPV(ST(i), len);
      str = lst_string_new(string, 1, len);
      /* Check each hash bucket for the string.  Would it be better to use
       *  find() ?
       */
      for (j = 0; j < LST_STRING_HASH_SIZE; j++) {
        hash = &tree->string_hash[j];
        for (hi = hash->lh_first; hi; hi = hi->items.le_next) {
          if (lst_string_get_length(hi->string) != len)
            continue;
          for (k = 0; k < len && lst_string_eq(str, k, hi->string, k); k++);
          if (k == len) {
            lst_stree_remove_string(tree, hi->string);
            done++;
            if (! tree->allow_duplicates)
              goto next_item;
          }
        }
      }
      next_item: 1;
      lst_string_free(str);
    }
    XSRETURN_IV(done);


void
_algorithm_longest_substrings (self, min_len=0, max_len=0)
    SV *self
    IV min_len
    IV max_len
  ALIAS:
    lcs = 1
    longest_common_substrings = 2
    lrs = 3
    longest_repeated_substrings = 4
  PROTOTYPE: $;$$
  PREINIT:
    LST_STree *tree;
    LST_StringSet *res;
    LST_String *str;
  PPCODE:
    tree = SV2TREE(self);
    if (ix > 2)
      res = lst_alg_longest_repeated_substring(tree, min_len, max_len);
    else
      res = lst_alg_longest_common_substring(tree, min_len, max_len);
    if (res) {
      EXTEND(SP, res->size);
      for (str = res->members.lh_first; str; str = str->set.le_next)
        PUSHs(sv_2mortal(newSVpv((char *)lst_string_print(str), 0)));
      lst_stringset_free(res);
    }


void
find (self, string)
    SV *self
    SV *string
  ALIAS:
    match = 1
    search = 2
  PROTOTYPE: $$
  PREINIT:
    LST_STree *tree;
    LST_String *str;
    LST_Edge *edge;
    LST_Node *node;
    AV *match;
    STRLEN len = 0;
  PPCODE:
    tree = SV2TREE(self);
    if (SvOK(string))
      len = SvCUR(string);
    if (len < 1)
      GIMME_V == G_ARRAY ? XSRETURN_EMPTY : XSRETURN_IV(0);
    str = lst_string_new(SvPV_nolen(string), 1, len);
    node = follow_string(tree, str);
    lst_string_free(str);
    if (! node)
      GIMME_V == G_ARRAY ? XSRETURN_EMPTY : XSRETURN_IV(0);
    /* Perform a depth-first search from matching node to find leafs. */
    TAILQ_HEAD(shead, lst_node) stack;
    TAILQ_INIT(&stack);
    TAILQ_INSERT_HEAD(&stack, node, iteration);
    while (node = stack.tqh_first) {
      TAILQ_REMOVE(&stack, stack.tqh_first, iteration);
      if (lst_node_is_leaf(node)) {
        match = (AV *)sv_2mortal((SV *)newAV());
        av_extend(match, 3);
        av_push(match, newSViv(lst_stree_get_string_index(tree, node->up_edge->range.string)));
        av_push(match, newSViv(node->index));
        av_push(match, newSViv(node->index + len - 1));
        XPUSHs(newRV_noinc((SV *)match));
      }
      for (edge = node->kids.lh_first; edge; edge = edge->siblings.le_next)
        TAILQ_INSERT_HEAD(&stack, edge->dst_node, iteration);
    }
    if (GIMME_V == G_SCALAR)
      XSRETURN_IV(SP - MARK);


SV *
string (self, id, start=0, end=-1)
    SV *self
    IV id
    IV start
    IV end
  PROTOTYPE: $$;$$
  PREINIT:
    LST_STree *tree;
    LST_StringHash *hash;
    LST_StringHashItem *hi;
    LST_StringIndex range;
    IV i;
  CODE:
    tree = SV2TREE(self);
    hash = &tree->string_hash[(id + 1) % LST_STRING_HASH_SIZE];
    for (hi = hash->lh_first; hi && hi->string->id != id + 1;
         hi = hi->items.le_next);
    if (! hi)
      XSRETURN_NO;
    lst_string_index_init(&range);
    range.string = hi->string;
    if (items < 4)
      end = hi->string->num_items - 1;
    if (start < 0)
      start = 0;
    /* Avoid print_func from returning "<eos>" */
    else if (start == hi->string->num_items - 1)
      start++;
    if (end < start)
      XSRETURN_NO;
    range.start_index = start;
    *(range.end_index) = end;
    RETVAL = newSVpv(hi->string->sclass->print_func(&range), 0);
  OUTPUT:
    RETVAL
