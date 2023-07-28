FROM docker.io/jekyll/builder

ENV GIT_REPO="https://github.com/mauricioscastro/blog"
ENV WORKDIR="/workdir"

ENTRYPOINT \
  repo_path=`echo $GIT_REPO | sed -e 's;.*/;;g'`; \
  function keep_pulling(){ cd $WORKDIR/$repo_path; while true; do sleep 10; git reset --hard; git pull -f; done; }; \
  cd $WORKDIR; \
  git clone $GIT_REPO; \
  cd $repo_path; \
  chmod -R a+rwx $WORKDIR; \
  bundle config set path $WORKDIR/bundle; \
  bundle install; \
  keep_pulling & \
  bundle exec jekyll serve -d $WORKDIR/site --host "0.0.0.0" --incremental

  

