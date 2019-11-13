#!/bin/bash -x
cd releases/$1  && \
# if need debug
#composer install --optimize-autoloader && \
composer install --no-dev --no-interaction --no-progress --optimize-autoloader && \

#build web socket
#cd mega-messages  && \
#npm install --no-bin-links --production && \

#build frontend
cd ../frontend  && \
npm install --no-bin-links --production && \
npm run production
