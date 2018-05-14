FROM lnls/epics-dist:base-3.15-debian-9

ENV IOC_REPO simioc
ENV BOOT_DIR ioclocalhost
ENV COMMIT master

# Install the EPICS stack
RUN apt-get update && \
    apt-get install -y \
        libpng-dev \
        libfreetype6-dev && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/lib/x86_64-linux-gnu/libpng16.so /usr/lib/x86_64-linux-gnu/libpng12.so

RUN git clone https://github.com/lerwys/${IOC_REPO}.git /opt/epics/${IOC_REPO} && \
    cd /opt/epics/${IOC_REPO} && \
    git checkout ${COMMIT} && \
    sed -i -e 's|^EPICS_BASE=.*$|EPICS_BASE=/opt/epics/base|' configure/RELEASE && \
    sed -i -e 's|^AREA_DETECTOR=.*$|AREA_DETECTOR=/opt/epics/synApps-lnls-R0-0-2/support/areaDetector-R3-2|' configure/RELEASE && \
    sed -i -e "\
    /^EPICS_BASE *=/ { \
        p; \
        s|.*||p; \
        s|.*|ASYN=/opt/epics/synApps-lnls-R0-0-2/support/asyn-R4-33|p; \
        s|.*|CALC=/opt/epics/synApps-lnls-R0-0-2/support/calc-R3-7|p; \
        s|.*|AUTOSAVE=/opt/epics/synApps-lnls-R0-0-2/support/autosave-R5-9|p; \
        s|.*|MOTOR=/opt/epics/synApps-lnls-R0-0-2/support/motor-R6-10|p; \
        s|.*|BUSY=/opt/epics/synApps-lnls-R0-0-2/support/busy-R1-7|p; \
        s|.*|ADSUPPORT=/opt/epics/synApps-lnls-R0-0-2/support/areaDetector-R3-2/ADSupport|p; \
        s|.*|ADSIMDETECTOR=/opt/epics/synApps-lnls-R0-0-2/support/areaDetector-R3-2/ADSimDetector|p; \
    }" configure/RELEASE && \
    sed -i -e 's|simioc_DBD += ADSupport.dbd||' simiocApp/src/Makefile && \
    sed -i -e 's|simioc_DBD += NDPluginSupport.dbd||' simiocApp/src/Makefile && \
    sed -i -e 's|simioc_DBD += motorRecord.dbd||' simiocApp/src/Makefile && \
    sed -i -e 's|simioc_LIBS += NDPlugin ADBase|simioc_LIBS += |' simiocApp/src/Makefile && \
    sed -i -e 's|PROD_LIBS += PvAPI||' simiocApp/src/Makefile && \
    make && \
    make install

# Source environment variables until we figure it out
# where to put system-wide env-vars on docker-debian
RUN . /root/.bashrc

WORKDIR /opt/epics/startup/ioc/${IOC_REPO}/iocBoot/${BOOT_DIR}
