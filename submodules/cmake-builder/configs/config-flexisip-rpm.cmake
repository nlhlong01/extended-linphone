############################################################################
# config-flexisip-rpm.cmake
# Copyright (C) 2014  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
############################################################################

include(GNUInstallDirs)
include(${CMAKE_SOURCE_DIR}/cmake/FindLinuxPlatform.cmake)

# Check if we have everything to compile correctly

FUNCTION(CHECK_PROGRAM progname)
	find_program(${progname}_PROGRAM
		NAMES ${progname}
	)
	if(NOT ${progname}_PROGRAM)
		message(FATAL_ERROR "Could not find the ${progname} program, which is needed for RPMBuild")
	else()
		message(STATUS "Found ${progname} : ${${progname}_PROGRAM}.")
	endif()
ENDFUNCTION()

FUNCTION(CHECK_LIBRARY libname)
	find_library(${libname}_LIBRARY
		NAMES ${libname}
		PATHS /usr/lib/mysql/
	)
	if(NOT ${libname}_LIBRARY)
		message(FATAL_ERROR "Could not find the ${libname} library, which is needed for RPMBuild of flexisip")
	else()
		message(STATUS "Found ${libname} : ${${libname}_LIBRARY}.")
	endif()
ENDFUNCTION()

# Doxygen can be found through CMake
find_package(Doxygen REQUIRED)

# the rest will be checked manually
FOREACH(PROGNAME rpmbuild bison)
	CHECK_PROGRAM(${PROGNAME})
ENDFOREACH()


set(FLEXISIP_LIBDEPS ssl mysqlclient_r mysqlclient)
if(PLATFORM STREQUAL "Debian")
	set(DEFAULT_VALUE_ENABLE_SOCI_BUILD ON)
endif()

FOREACH(LIBNAME ${FLEXISIP_LIBDEPS})
	CHECK_LIBRARY(${LIBNAME})
ENDFOREACH()


# Define default values for the flexisip builder options
set(DEFAULT_VALUE_DISABLE_BC_ANTLR ON)
set(DEFAULT_VALUE_ENABLE_ODBC OFF)
set(DEFAULT_VALUE_ENABLE_PUSHNOTIFICATION ON)
set(DEFAULT_VALUE_ENABLE_REDIS ON)
set(DEFAULT_VALUE_ENABLE_SOCI ON)
set(DEFAULT_VALUE_ENABLE_UNIT_TESTS OFF)
set(DEFAULT_VALUE_CMAKE_LINKING_TYPE "-DENABLE_STATIC=NO")
set(DEFAULT_VALUE_ENABLE_BC_HIREDIS ON)

# Global configuration
set(LINPHONE_BUILDER_HOST "")

set(RPM_INSTALL_PREFIX "/opt/belledonne-communications")

# Adjust PKG_CONFIG_PATH to include install directory
if(UNIX)
	set(LINPHONE_BUILDER_PKG_CONFIG_PATH "${RPM_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/pkgconfig/:${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/pkgconfig/:$ENV{PKG_CONFIG_PATH}:/usr/${CMAKE_INSTALL_LIBDIR}/pkgconfig/:/usr/${CMAKE_INSTALL_LIBDIR}/x86_64-linux-gnu/pkgconfig/:/usr/share/pkgconfig/:/usr/local/${CMAKE_INSTALL_LIBDIR}/pkgconfig/:/opt/local/${CMAKE_INSTALL_LIBDIR}/pkgconfig/")
	message(STATUS "PKG CONFIG PATH: ${LINPHONE_BUILDER_PKG_CONFIG_PATH}")
	message(STATUS "LIBDIR: ${LIBDIR}")
else() # Windows
	set(LINPHONE_BUILDER_PKG_CONFIG_PATH "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/")
endif()


# we can override the bctoolbox build method before including builders because it doesn't define it.
set(EP_bctoolbox_BUILD_METHOD "rpm")
lcb_builder_cmake_options(bctoolbox "-DENABLE_TESTS=NO")
lcb_builder_cmake_options(bctoolbox "-DENABLE_TESTS_COMPONENT=NO")

lcb_builder_cmake_options(ms2 "-DENABLE_SRTP=NO") #mainly to avoid issue with old libsrtp (sha1_update conflict with polarssl)
set(EP_ms2_BUILD_METHOD "rpm")
set(EP_ortp_BUILD_METHOD     "rpm")
# Include builders
include(builders/CMakeLists.txt)

set(EP_bellesip_BUILD_METHOD "rpm")
set(EP_sofiasip_BUILD_METHOD "rpm")
set(EP_flexisip_BUILD_METHOD "rpm")
set(EP_odb_BUILD_METHOD      "custom")

set(EP_ms2_SPEC_PREFIX     "${RPM_INSTALL_PREFIX}")
set(EP_ortp_SPEC_PREFIX     "${RPM_INSTALL_PREFIX}")
set(EP_bellesip_SPEC_PREFIX "${RPM_INSTALL_PREFIX}")
set(EP_sofiasip_SPEC_PREFIX "${RPM_INSTALL_PREFIX}")
set(EP_flexisip_SPEC_PREFIX "${RPM_INSTALL_PREFIX}")

set(EP_ortp_RPMBUILD_OPTIONS      "--with bc")
set(EP_ms2_RPMBUILD_OPTIONS       "--with bc --without video --without srtp")
set(EP_unixodbc_RPMBUILD_OPTIONS  "--with bc")
set(EP_myodbc_RPMBUILD_OPTIONS    "--with bc")
set(EP_sofiasip_RPMBUILD_OPTIONS  "--with bc --without glib")
set(EP_hiredis_RPMBUILD_OPTIONS   "--with bc" )
if (ENABLE_TRANSCODER)
	set(EP_flexisip_RPMBUILD_OPTIONS  "--with bc --with push")
else()
	set(EP_flexisip_RPMBUILD_OPTIONS  "--with bc --without transcoder --with push")
endif()

set(EP_bellesip_RPMBUILD_OPTIONS  "--with bc ")

if (ENABLE_PRESENCE)
	lcb_builder_rpmbuild_name("flexisip" "flexisip-presence")
	set(EP_flexisip_RPMBUILD_OPTIONS "${EP_flexisip_RPMBUILD_OPTIONS} --with presence")
endif()

if (ENABLE_SOCI)
	set(soci_filename "soci-3.2.3.tar.gz")
	set(EP_soci_URL "${CMAKE_CURRENT_SOURCE_DIR}/builders/soci/${soci_filename}")
	set(EP_soci_URL_HASH "SHA1=5e527cf5c1740198fa706fc8821af45b34867ee1")

	set(EP_soci_BUILD_METHOD "rpm")
	set(EP_soci_SPEC_FILE "soci.spec" )
	set(EP_soci_CONFIG_H_FILE "${CMAKE_CURRENT_SOURCE_DIR}/builders/soci/${EP_soci_SPEC_FILE}" )
	set(EP_soci_RPMBUILD_OPTIONS "--without postgresql --without sqlite3 --without odbc --with mysql --without oracle --define 'soci_patch ${CMAKE_CURRENT_SOURCE_DIR}/builders/soci/soci_libdir.patch'")

	#create source dir and copy the tar.gz inside
	set(EP_soci_PATCH_COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${LINPHONE_BUILDER_WORK_DIR}/rpmbuild/SOURCES/")
	set(EP_soci_PATCH_COMMAND ${EP_soci_PATCH_COMMAND} "COMMAND" "${CMAKE_COMMAND}" "-E" "copy" "${EP_soci_URL}" "${LINPHONE_BUILDER_WORK_DIR}/rpmbuild/SOURCES/")
	set(EP_soci_PATCH_COMMAND ${EP_soci_PATCH_COMMAND} "COMMAND" "${CMAKE_COMMAND}" "-E" "copy" "${CMAKE_CURRENT_SOURCE_DIR}/builders/soci/soci_libdir.patch" "${LINPHONE_BUILDER_WORK_DIR}/rpmbuild/SOURCES/")
	set(EP_soci_PATCH_COMMAND ${EP_soci_PATCH_COMMAND} "COMMAND" "${CMAKE_COMMAND}" "-E" "copy" ${EP_soci_CONFIG_H_FILE} "<BINARY_DIR>")

	# no configure needed for soci
	set(EP_soci_CONFIGURE_COMMAND_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/builders/soci/configure.sh.cmake)

	set(EP_flexisip_RPMBUILD_OPTIONS "${EP_flexisip_RPMBUILD_OPTIONS} --with soci")
endif()

if (ENABLE_SNMP)
	set(EP_flexisip_RPMBUILD_OPTIONS "${EP_flexisip_RPMBUILD_OPTIONS} --with snmp")
endif()

if(ENABLE_BC_ODBC)
	set(EP_unixodbc_BUILD_METHOD       "rpm")
	set(EP_myodbc_BUILD_METHOD         "rpm")
	set(EP_unixodbc_SPEC_PREFIX        "${RPM_INSTALL_PREFIX}")
	set(EP_myodbc_SPEC_PREFIX          "${RPM_INSTALL_PREFIX}")
	set(EP_myodbc_CONFIGURE_OPTIONS    "--with-unixODBC=${RPM_INSTALL_PREFIX}")
	set(EP_flexisip_RPMBUILD_OPTIONS   "${EP_flexisip_RPMBUILD_OPTIONS} --with bcodbc")
	list(APPEND EP_flexisip_CONFIGURE_OPTIONS "--with-odbc=${RPM_INSTALL_PREFIX}")
endif()

set(LINPHONE_BUILDER_RPMBUILD_PACKAGE_PREFIX "bc-")

# prepare the RPMBUILD options that we need to pass

set(RPMBUILD_OPTIONS "--define '_mandir %{_prefix}'")

if(PLATFORM STREQUAL "Debian")
	# dependencies cannot be checked by rpmbuild in debian
	set(RPMBUILD_OPTIONS "${RPMBUILD_OPTIONS} --nodeps")

	# dist is not defined in debian for rpmbuild..
	set(RPMBUILD_OPTIONS "${RPMBUILD_OPTIONS} --define 'dist .deb'")

	# debian has multi-arch lib dir instead of lib and lib64
	set(RPMBUILD_OPTIONS "${RPMBUILD_OPTIONS} --define '_lib lib'")

	# debian has multi-arch lib dir instead of lib and lib64
	set(RPMBUILD_OPTIONS "${RPMBUILD_OPTIONS} --define '_libdir %{_prefix}/%{_lib}'")

	# some debians are using dash as shell, which doesn't support "export -n", so we override and use bash
	set(RPMBUILD_OPTIONS "${RPMBUILD_OPTIONS} --define '_buildshell /bin/bash'")

	CHECK_PROGRAM(alien)
	CHECK_PROGRAM(fakeroot)
endif()

set(LINPHONE_BUILDER_RPMBUILD_GLOBAL_OPTION ${RPMBUILD_OPTIONS})
