{
#
# Name of the script RB-SETFW (rb-setfw.rsc) vers. 2022022002
# this script is for setting specified firmware RouterOS version (upgrade or downgrade) to the RouterBoard
# Copyright Igor Alov (alov.igor@gmail.com)
#
# rqvers please specify required version
# debug flag will allow to get more verbose level
#

:local debug false
:local rqvers "6.49.1"
:local rbvers ""
:local rbarch ""
:local rburl ""
:local rbact 0

 # function to convert versions into shifted digits
:local ConvertRouterBoardVersion do={
   :if ( $debug ) do={ :put "Function CONVERR RBVersion: $RBVersion" }
   :local posS 0
   :local posE 0
   :if ( [:len $RBVersion] > 0) do={
      :set posS [:find $RBVersion "." 0 ]
      :set posE [:find $RBVersion "." $posS ]
      :if ( [:len $posS] = 0 or $posS = $posE ) do={
         :log debug "Could not parse RB version $RBVersion"
         :error "Could not parse RB version $RBVersion"
      } else={
         :local mjr [:tonum [:pick $RBVersion 0 $posS ]]
         :local min 0
         :local sub 0
         :if ($posE > $posS ) do={
            :set min [:tonum [:pick $RBVersion ($posS+1) $posE ]]
            :set sub [:tonum [:pick $RBVersion ($posE+1) 99]]
         } else={ 
            :set min [:tonum [:pick $RBVersion ($posS+1) 99 ]]
            }
         :local result  (($mjr<<16) + ($min<<8) + $sub)
         :if ( $debug ) do={ :put "$mjr, $min, $sub: $result" }
         :return $result
         }
   } else={
      :log debug "Not found variable RBVersion"
      :error "Not found variable RBVersion"
      }
   }
# function to comparing number of two versions
:local CompareRouterBoardVersion do={
   #comapring versions
   :if ( [:len $RBCUR ] > 0 and [:len $RBREQ ] > 0 ) do={
         :local cur 0
         :local req 0
         :set cur [ $ConvertRouterBoardVersion RBVersion=$RBCUR debug=$debug ]
         :set req [ $ConvertRouterBoardVersion RBVersion=$RBREQ debug=$debug ]
         :if ( $debug ) do={ :put "Function COMPARE RBVersion: RBCUR: $RBCUR [ $cur ]; RBREQ: $RBREQ [ $req ];" }
         :if ( $cur=0 or $req=0) do={
            :log debug "Could not compare RB versions [ $RBREQ; $RBCUR]"
            :error "Could not compare RB versions [ $RBREQ; $RBCUR]"
         } else={
            :local result 0
            :if ( $cur > $req) do={ :set result 2 }
            :if ($cur < $req ) do={ :set result 1 }
            :return $result
            }
   } else={
      :log debug "Not found variables RBCUR or RBREQ"
      :error "Not found variables RBCUR or RBREQ"
      }
   }

:set rbvers [:pick [ /system resource get version ] 0 [:find [ /system resource get version ] " "] ]
:set rbarch [ /system resource get architecture-name ]

#check if we get version correctly
:if ( [:len $rbvers] = 0 ) do={
   :log debug "Can NOT get current RB Version"
   :error "Can NOT current RB Version"
   }
#check if we get arch correctly
:if ( [:len $rbarch] = 0 ) do={
   :log debug "Can NOT get RB Arch"
   :error "Can NOT get RB Arch"
   }

:set rbact [ $CompareRouterBoardVersion RBCUR=$rbvers RBREQ=$rqvers ConvertRouterBoardVersion=$ConvertRouterBoardVersion debug=$debug ]
:if ( $debug ) do={ :put "RBACTION: $rbact" }

:if ( $rbact = 0 ) do={ 
   :log warning "Routerboard Firmware: No action is required [ RBACCT: $rbact ]."
} else={
   :set rburl "https://download.mikrotik.com/routeros/$rqvers/routeros-$rbarch-$rqvers.npk"
   :log warning "RB Info: $rbvers [ $rbarch ], URL: $rburl, [ RBACCT: $rbact ]."
   /tool fetch url="$rburl" mode=https ascii=no keep-result=yes 
   :if ( $rbact = 1 ) do={
      :if ( $debug ) do={ :put "upgrading firmware...." }
      /system reboot 
   } else={
      :if ( $rbact = 2 ) do={
         :if ( $debug) do={ :put "downgrading firmware...." }
         /system package downgrade 
      } else={
         :log debug "Wrong action [ RBACCT: $rbact ]. Can NOT flush device"
         :error "Wrong action [ RBACCT: $rbact ]. Can NOT flush device"
         }
      }
   }

# This is examples for the functions
:if ( $debug ) do={
   :put "convert test"
   :put [$ConvertRouterBoardVersion RBVersion=6.49.1 debug=$debug ]
   :put [$ConvertRouterBoardVersion RBVersion=6.49 debug=$debug ]
   :put [$ConvertRouterBoardVersion RBVersion=6.48.1 debug=$debug ]
   :put "compare test"
   :put [ $CompareRouterBoardVersion RBCUR=6.48.1 RBREQ=6.49.1 ConvertRouterBoardVersion=$ConvertRouterBoardVersion debug=$debug ]
   :put [ $CompareRouterBoardVersion RBCUR=6.49.3 RBREQ=6.49.1 ConvertRouterBoardVersion=$ConvertRouterBoardVersion debug=$debug ]
   :put [ $CompareRouterBoardVersion RBCUR=6.48 RBREQ=6.49.1 ConvertRouterBoardVersion=$ConvertRouterBoardVersion debug=$debug ]
   :put [ $CompareRouterBoardVersion RBCUR=6.49.1 RBREQ=6.49.1 ConvertRouterBoardVersion=$ConvertRouterBoardVersion debug=$debug ]
   }

}
/file remove [/file find name=rb-setfw.rsc]
