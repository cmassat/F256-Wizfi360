response .namespace
.section code
.endsection

.section variables
wi_fi_message
    .text 'FI GOT IP',$0D,$0a
wi_fi_message_end
wi_fi_message_length = wi_fi_message_end - wi_fi_message

ready_message
    .text $0D,$0a,'ready',$0D,$0a
ready_message_end
ready_message_length = ready_message_end - ready_message

error_message
    .text 'ERROR',$0D,$0a
error_message_end
error_message_length = error_message_end - error_message

ok_message
    .text 'OK',$0D,$0a
ok_message_end
ok_message_length = ok_message_end - ok_message
.endsection
.endnamespace