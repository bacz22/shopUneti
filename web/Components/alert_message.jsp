<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@page import="entities.Message"%>

<%
    /* Lấy message từ session */
    Message msg = (Message) session.getAttribute("message");

    if (msg != null) {
        
        String iconType = "info";
        if (msg.getMessageType() != null) {
            if (msg.getMessageType().equals("success")) {
                iconType = "success";
            } else if (msg.getMessageType().equals("error")) {
                iconType = "error";
            }
        }
%>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    /* Lớp .swal2-container là bao ngoài của popup.
       Chúng ta tăng z-index lên cực cao và đẩy nó xuống dưới.
    */
    div.swal2-container {
        z-index: 20000 !important; /* Đảm bảo luôn nằm trên Navbar (thường Navbar chỉ tầm 1000-2000) */
    }

    div.swal2-top-end {
        /* Thay đổi 80px thành chiều cao thực tế của Navbar web bạn nếu cần */
        top: 80px !important; 
    }
</style>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',    
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer)
                toast.addEventListener('mouseleave', Swal.resumeTimer)
            }
        });

        Toast.fire({
            icon: '<%= iconType %>',
            title: '<%= msg.getMessage() %>'
        });
    });
</script>

<%
        session.removeAttribute("message");
    }
%>