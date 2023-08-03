FROM docker.io/jekyll/builder

ENV WORKDIR="/workdir"
ENV GIT_REPO="https://github.com/mauricioscastro/blog"
ENV GIT_SSH_KEY="$WORKDIR/gitkey"

ENTRYPOINT \
  repo_path=`echo $GIT_REPO | sed -e 's/.git//g' -e 's;.*/;;g'`; \
  function keep_pulling(){ chmod 0400 $GIT_SSH_KEY; cd $WORKDIR/$repo_path; while true; do sleep 10; git reset --hard > /dev/null; git pull 2> /dev/null; done; }; \
  if [ `echo $GIT_REPO | egrep -c "^http"` -eq 0 ]; then export GIT_SSH_COMMAND="ssh -i $GIT_SSH_KEY -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"; fi; \
  chmod 0400 $GIT_SSH_KEY; \
  cd $WORKDIR; \
  git clone $GIT_REPO; \
  cd $repo_path; \
  chmod -R a+rwx $WORKDIR; \
  bundle config set path $WORKDIR/bundle; \
  bundle install; \
  keep_pulling & \
  bundle exec jekyll serve -w -d $WORKDIR/site --host "0.0.0.0" --incremental

  

