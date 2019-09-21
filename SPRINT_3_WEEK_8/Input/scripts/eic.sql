
print 'DISABLING Enabler Card Ports (1-5) to allow operation with EIC'
/*  to undo this - update the types back to zero */
update loops 
   set connection_type = 3
 where loop_id < 6
go

/* 
 connection_type = 3 for a USB connected EIC
 port_assign = 11,12,13 for EIC 1 PDM 1,2,3  21,22,23 for EIC 2 PDM 1,2,3, etc
 */
print 'Inserting 3 port rows for EIC 1'
insert into loops( loop_id , port_assign, port_name, connection_type, protocol_id ) values ( 6, 11, 'EIC 1 PDM 1', 3, 11 )
go
insert into loops( loop_id , port_assign, port_name, connection_type, protocol_id ) values ( 7, 12, 'EIC 1 PDM 2', 3, 11 )
go
insert into loops( loop_id , port_assign, port_name, connection_type, protocol_id ) values ( 8, 13, 'EIC 1 PDM 3', 3, 3 )
go


