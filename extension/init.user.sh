#!/bin/sh

TEMP=$(mktemp -d) &&
    echo "${GPG_SECRET_KEY}" > ${TEMP}/gpg-secret-key &&
    gpg --batch --import ${TEMP}/gpg-secret-key &&
    echo "${GPG2_SECRET_KEY}" > ${TEMP}/gpg2-secret-key &&
    gpg2 --batch --import ${TEMP}/gpg2-secret-key &&
    echo "${GPG_OWNER_TRUST}" > ${TEMP}/gpg-owner-trust &&
    gpg --batch --import-ownertrust ${TEMP}/gpg-owner-trust &&
    echo "${GPG2_OWNER_TRUST}" > ${TEMP}/gpg2-owner-trust &&
    gpg2 --batch --import-ownertrust ${TEMP}/gpg2-owner-trust &&
    rm -rf ${TEMP} &&
    pass init $(gpg --list-keys | grep "^pub" | sed -e "s#^.*/##" -e "s# .*\$##") &&
    pass git init &&
    pass git config user.name "${COMMITTER_NAME}" &&
    pass git config user.email "${COMMITTER_EMAIL}" &&
    pass git remote add origin origin:${ORIGIN_ORGANIZATION}/${ORIGIN_REPOSITORY}.git &&
    echo "${ORIGIN_ID_RSA}" > /home/user/.ssh/origin_id_rsa &&
    ssh-keyscan -p ${ORIGIN_PORT} "${ORIGIN_NAME}" > /home/user/.ssh/known_hosts &&
    (cat > /home/user/.ssh/config <<EOF
Host origin
HostName ${ORIGIN_NAME}
Port ${ORIGIN_PORT}
User git
IdentityFile ~/.ssh/origin_id_rsa
EOF
    ) &&
    pass git fetch origin master &&
    pass git checkout master &&
    if [ ! -z "${READ_WRITE}" ]
    then
        ln -sf /usr/local/bin/post-commit ${HOME}/.password-store/.git/hooks
    fi &&
    if [ ! -z "${READ_ONLY}" ]
    then
        ln -sf /usr/local/bin/pre-comit ${HOME}/.password-store/.git/hooks
    fi