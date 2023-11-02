# TCL File Generated by Component Editor 17.0
# Thu Nov 02 09:58:47 UTC 2023
# DO NOT MODIFY


# 
# new_component "new_component" v1.0
#  2023.11.02.09:58:47
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module new_component
# 
set_module_property DESCRIPTION ""
set_module_property NAME new_component
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME new_component
set_module_property INSTANTIATE_IN_SYSTEM_MODULE false
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 

# 
# parameters
# 


# 
# display items
# 


# 
# connection point avs_s0
# 
add_interface avs_s0 avalon end
set_interface_property avs_s0 addressUnits WORDS
set_interface_property avs_s0 associatedClock clock
set_interface_property avs_s0 associatedReset reset
set_interface_property avs_s0 bitsPerSymbol 8
set_interface_property avs_s0 bridgedAddressOffset 0
set_interface_property avs_s0 burstOnBurstBoundariesOnly false
set_interface_property avs_s0 burstcountUnits WORDS
set_interface_property avs_s0 explicitAddressSpan 0
set_interface_property avs_s0 holdTime 0
set_interface_property avs_s0 linewrapBursts false
set_interface_property avs_s0 maximumPendingReadTransactions 0
set_interface_property avs_s0 maximumPendingWriteTransactions 0
set_interface_property avs_s0 readLatency 0
set_interface_property avs_s0 readWaitTime 1
set_interface_property avs_s0 setupTime 0
set_interface_property avs_s0 timingUnits Cycles
set_interface_property avs_s0 writeWaitTime 0
set_interface_property avs_s0 ENABLED true
set_interface_property avs_s0 EXPORT_OF ""
set_interface_property avs_s0 PORT_NAME_MAP ""
set_interface_property avs_s0 CMSIS_SVD_VARIABLES ""
set_interface_property avs_s0 SVD_ADDRESS_GROUP ""

add_interface_port avs_s0 avs_s0_address address Input 8
add_interface_port avs_s0 avs_s0_read read Input 1
add_interface_port avs_s0 avs_s0_readdata readdata Output 32
add_interface_port avs_s0 avs_s0_write write Input 1
add_interface_port avs_s0 avs_s0_writedata writedata Input 32
add_interface_port avs_s0 avs_s0_waitrequest waitrequest Output 1
set_interface_assignment avs_s0 embeddedsw.configuration.isFlash 0
set_interface_assignment avs_s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avs_s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avs_s0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clock_clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point ins_irq0
# 
add_interface ins_irq0 interrupt end
set_interface_property ins_irq0 associatedAddressablePoint avs_s0
set_interface_property ins_irq0 associatedClock clock
set_interface_property ins_irq0 associatedReset reset
set_interface_property ins_irq0 bridgedReceiverOffset 0
set_interface_property ins_irq0 bridgesToReceiver ""
set_interface_property ins_irq0 ENABLED true
set_interface_property ins_irq0 EXPORT_OF ""
set_interface_property ins_irq0 PORT_NAME_MAP ""
set_interface_property ins_irq0 CMSIS_SVD_VARIABLES ""
set_interface_property ins_irq0 SVD_ADDRESS_GROUP ""

add_interface_port ins_irq0 ins_irq0_irq irq Output 1

