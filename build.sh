#!/bin/bash
pandoc --from markdown+pipe_tables+strikeout+task_lists+gfm_auto_identifiers+autolink_bare_uris+emoji \
       --metadata-file master.yaml \
       --template template.tex \
       --pdf-engine=xelatex \
       --lua-filter gfm-to-latex.lua \
       First_File \
       Second_File \
       -o output.pdf

echo "PDF generated"