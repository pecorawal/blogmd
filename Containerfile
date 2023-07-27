FROM jekyll/builder

ENV GIT_REPO="https://github.com/mauricioscastro/blog"
ENV WORKDIR="/workdir"

ENTRYPOINT \
  cd $WORKDIR; \
  git clone $GIT_REPO; \
  cd `echo $GIT_REPO | sed -e 's;.*/;;g'`; \
  bundle config set path $WORKDIR/bundle; \
  bundle install; \
  bundle exec jekyll serve -d $WORKDIR/site --host "0.0.0.0" --incremental

  

