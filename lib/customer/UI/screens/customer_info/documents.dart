import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tdlogistic_v2/customer/UI/screens/customer_info/info_display_page.dart';
import 'package:tdlogistic_v2/customer/UI/screens/customer_info/services.dart';

enum DocumentType { text, multiImage, placeholder }

class TermsAndDocumentsPage extends StatelessWidget {
  const TermsAndDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> documents = [
      {
        'id': 'business_license',
        'title': 'Giấy phép kinh doanh',
        'icon': Icons.business_center_outlined,
        'type': DocumentType.text,
      },
      {
        'id': 'services',
        'title': 'Giới thiệu dịch vụ TDLogistics',
        'icon': Icons.info_outline,
        'type': DocumentType.text,
      },
      {
        'id': 'buu_chinh',
        'title': 'Giấy phép bưu chính',
        'icon': Icons.mail_outline,
        'type': DocumentType.multiImage,
        'data': [
          'https://tdlogistics.net.vn/_next/image?url=%2Flicense%2F0005.jpg&w=3840&q=75',
          'https://tdlogistics.net.vn/_next/image?url=%2Flicense%2F0004.jpg&w=3840&q=75',
          'https://tdlogistics.net.vn/_next/image?url=%2Flicense%2F0003.jpg&w=3840&q=75',
        ],
      },
      {
        'id': 'policy',
        'title': 'Điều khoản dịch vụ',
        'icon': Icons.description_outlined,
        'type': DocumentType.text,
        'data': """
ĐIỀU KHOẢN VÀ ĐIỀU KIỆN SỬ DỤNG ỨNG DỤNG TDLOGISTICS
Điều 1. Quy định chung:
Bằng việc tải xuống, cài đặt, và/hoặc sử dụng Ứng dụng TDLogistics (sau đây gọi là "Ứng Dụng") để sử dụng các dịch vụ của Tổng Công ty CP Bưu chính TD, Người sử dụng Ứng dụng (sau đây gọi là "Khách Hàng") đồng ý rằng: Khách hàng đã đọc, đã hiểu và đồng ý với các nội dung trong Điều khoản và điều kiện sử dụng ứng dụng TDLogistics này (sau đây gọi là "Điều Khoản Sử Dụng"). Điều Khoản Sử Dụng này cấu thành một thỏa thuận giữa Khách Hàng và Tổng Công ty cổ phần Bưu chính TD (sau đây gọi là "TDLogistics") và được công bố trên Ứng Dụng.
Nếu không đồng ý với bất kỳ nội dung nào của Điều Khoản Sử Dụng, Khách hàng vui lòng không tạo tài khoản sử dụng Ứng Dụng, không đăng ký/kích hoạt/sử dụng Dịch Vụ và tháo gỡ Ứng Dụng ra khỏi thiết bị của mình. Việc tiếp tục sử dụng Ứng Dụng sau thời điểm thông báo về các nội dung sửa đổi, bổ sung trong từng thời kỳ sẽ đồng nghĩa với việc Khách Hàng đã chấp nhận các nội dung của Điều Khoản Sử Dụng.
TDLogistics có quyền sửa đổi, bổ sung bất cứ nội dung nào tại bản Điều Khoản Sử Dụng này vào bất kì thời điểm nào mà TDLogistics cho là phù hợp. TDLogistics sẽ thông báo cho Khách Hàng về những chỉnh sửa, thay đổi Điều Khoản Sử Dụng hoặc các chính sách có liên quan đến Dịch Vụ thông qua Ứng Dụng trước thời điểm có hiệu lực ít nhất 24 giờ. Phiên bản cập nhật sẽ được đăng tải trên Ứng Dụng. Khách Hàng xác nhận và đồng ý rằng Khách Hàng phải có trách nhiệm thường xuyên kiểm tra Điều Khoản Sử Dụng. Việc tiếp tục sử dụng Ứng Dụng sau khi có bất kỳ thay đổi nào, bất kể là Khách Hàng đã xem xét nội dung thay đổi hay chưa, sẽ đồng nghĩa với việc Khách Hàng đã chấp thuận và đồng ý đối với những thay đổi đó.
Điều 2. Giải thích từ ngữ
Trong phạm vi Điều khoản sử dụng này, trừ trường hợp ngữ cảnh có quy định khác, các từ ngữ sau đây được hiểu như sau:

Ứng dụng TDLogistics là ứng dụng do Tổng Công ty cổ phần Bưu chính TD sở hữu và vận hành hoạt động, cho phép Khách hàng tạo đơn hàng để sử dụng dịch vụ chấp nhận, vận chuyển và phát bưu gửi bằng các phương thức từ địa điểm của người gửi đến địa điểm của người nhận của TDLogistics.
Dịch Vụ là dịch vụ bưu chính do TDLogistics cung cấp qua Ứng dụng TDLogistics.
Khách Hàng là tổ chức, cá nhân đăng ký tài khoản trên Ứng Dụng để sử dụng Dịch Vụ của TDLogistics.
Bưu gửi bao gồm thư, gói, kiện hàng hoá, tài sản hợp pháp, hợp lệ được TDLogistics chấp nhận, vận chuyển qua mạng bưu chính.
COD (Cash on Delivery) là phương thức thanh toán bằng tiền mặt khi giao hàng.
Đơn hàng là yêu cầu sử dụng Dịch Vụ được Khách Hàng khởi tạo trên Ứng Dụng.
Đơn hàng được chấp nhận là Đơn hàng đã được Nhân viên của TDLogistics tiếp nhận vật lý và được xác nhận trên Ứng Dụng và Hệ thống quản lý giao dịch đã ghi nhận các thông tin về người gửi, người nhận, bưu gửi, và thông tin về hành trình thư; cước phí, có giá trị chứng cứ về việc xác lập và thực hiện.
Thông tin người nhận gồm các thông tin về họ tên, điện thoại, địa chỉ và thông tin khác của Người nhận.
Thời gian toàn trình của bưu gửi là khoảng thời gian được tính từ khi bưu gửi được chấp nhận cho đến khi được phát cho Người nhận.
Người gửi là tổ chức, cá nhân có tên tại phần ghi thông tin về người gửi trên bưu gửi, trên Đơn hàng.
Người nhận là tổ chức, cá nhân có tên tại phần ghi thông tin về người nhận trên bưu gửi, trên Đơn hàng.
Điều 3. Mô tả Dịch Vụ
Ứng dụng TDLogistics là một ứng dụng thương mại điện tử trên thiết bị di động do TDLogistics thiết lập để phục vụ hoạt động xúc tiến thương mại, cung ứng Dịch Vụ cho Khách Hàng. Các Dịch Vụ bưu chính mà TDLogistics cung cấp bao gồm nhưng không giới hạn:
Dịch vụ chuyển phát nhanh
Dịch vụ chuyển phát hỏa tốc
Dịch vụ chuyển phát tiết kiệm
Dịch vụ phát hàng thu tiền hộ (COD)
Dịch vụ gửi hàng quốc tế
Tính năng nổi bật của Ứng Dụng:
Tạo đơn thao tác nhanh
Quản lý đơn hàng đơn giản và tiện lợi
Theo dõi quá trình giao hàng mọi lúc mọi nơi, thông báo kịp thời, chính xác
Tra cứu các điểm gửi hàng của TDLogistics trên khắp cả nước
Tính trước cước phí nhanh chóng và chính xác
Quản lý đối soát, tiền COD dễ dàng và nhanh chóng
Cập nhật tin tức, ưu đãi từ TDLogistics nhanh nhất
Chat với nhân viên TDLogistics và các tính năng hữu ích khác
TDLogistics có thể theo chính sách riêng của mình để đưa ra các chương trình khuyến mại. Khách Hàng đồng ý rằng sẽ chỉ sử dụng các chương trình khuyến mại đúng mục đích và sẽ không lạm dụng, sao chép, bán hoặc chuyển nhượng khuyến mại dưới bất kỳ hình thức nào. Khách Hàng cũng hiểu rằng các khuyến mại không thể quy đổi thành tiền và có thể hết hạn vào một ngày thực tế, thậm chí trước khi Khách Hàng sử dụng.
Cách đăng ký: Khách Hàng chỉ có thể sử dụng Ứng Dụng khi đã đăng ký tài khoản bằng cách điền đầy đủ thông tin và chấp nhận Điều Khoản Sử Dụng của Ứng Dụng. Khi đã đăng ký thành công, Ứng Dụng sẽ cung cấp cho Khách Hàng một tài khoản cá nhân có thể truy cập bằng mật khẩu mà Khách Hàng chọn. Khách Hàng có nghĩa vụ bảo mật, không tiết lộ cho bất kỳ ai tài khoản và mật khẩu của mình. Khách Hàng cũng hiểu rằng, trong mọi trường hợp, người sử dụng tài khoản, mật khẩu của Khách Hàng để đăng nhập Ứng Dụng đều được hiểu là Khách Hàng và Khách Hàng phải chịu trách nhiệm với tất cả các Đơn hàng, thao tác trên Ứng Dụng do tài khoản của Khách Hàng thực hiện.
Điều 4. Phí Dịch Vụ
Biểu phí Dịch Vụ được TDLogistics quy định trong từng thời kỳ và được thông báo công khai trên Ứng Dụng hoặc trang thông tin điện tử của TDLogistics tại địa chỉ: https://tdlogistics.com.vn/dich-vu hoặc niêm yết tại các kênh giao dịch của TDLogistics.
TDLogistics có quyền quy định, thay đổi mức phí của các loại phí liên quan đến Dịch Vụ. Biểu phí thay đổi sẽ có giá trị (ràng buộc) nếu Khách Hàng tiếp tục sử dụng dịch vụ ngay sau khi biểu phí mới có hiệu lực (ngày biểu phí mới có hiệu lực).
Nếu Khách Hàng không đồng ý với mức phí đưa ra, Khách Hàng có quyền không sử dụng Dịch Vụ.
Điều 5. Chính sách vận chuyển
Tạo Đơn hàng
Khách Hàng phải điền chính xác thông tin bưu gửi, bao gồm: nội dung bưu gửi, thông tin người nhận, thông tin người gửi, trọng lượng bưu gửi,... và chịu trách nhiệm về các thông tin này. Trường hợp, TDLogistics phát hiện thông tin bưu gửi không chính xác thì TDLogistics được quyền yêu cầu Khách Hàng chỉnh sửa thông tin hoặc tự động chỉnh sửa thông tin (nếu có thể) hoặc từ chối cung cấp Dịch Vụ hoặc ngừng Dịch Vụ, hoàn bưu gửi (nếu đã tiếp nhận). Khách Hàng có nghĩa vụ thanh toán tất cả các chi phí phát sinh từ hành vi khai báo/điền thông tin không chính xác.
Khách Hàng được quyền lựa chọn Dịch Vụ theo nhu cầu của mình, đồng thời Khách Hàng cũng hiểu rằng với mỗi loại Dịch Vụ sẽ có mức phí dịch vụ khác nhau, chất lượng khác nhau và mức giới hạn trách nhiệm bồi thường khác nhau. Khách Hàng cam kết sẽ không yêu cầu bồi thường vượt quá mức giới hạn trách nhiệm bồi thường của TDLogistics nếu có sự cố.
Hủy Đơn hàng
Hủy Đơn hàng bởi Khách hàng: Khách hàng có quyền thực hiện hủy Đơn hàng đã đặt trước khi bàn giao bưu gửi vật lý cho nhân viên của TDLogistics.
Hủy Đơn hàng bởi TDLogistics: TDLogistics có quyền thực hiện hủy Đơn hàng hoặc không chấp nhận bưu gửi hoặc ngừng cung cấp Dịch Vụ đối với bưu gửi đã chấp nhận nếu bưu gửi không đảm bảo yêu cầu vận chuyển và/hoặc điều kiện cung ứng Dịch Vụ của TDLogistics hoặc phát hiện nội dung bưu gửi là hàng hóa cấm lưu thông/kinh doanh,... theo quy định tại Điều Khoản Sử Dụng này và quy định của pháp luật hiện hành.
Chính sách gửi giữ: Trường hợp bưu gửi đã được chuyển đến địa điểm giao hàng đúng thời hạn nhưng không có người nhận hàng thì TDLogistics có thể gửi hàng cho người thứ ba được Khách Hàng chỉ định nhận hàng. Khách Hàng và người thứ ba được Khách Hàng chỉ định phải chịu chi phí hợp lý phát sinh từ việc gửi giữ bưu gửi.
Quy định về hoàn trả bưu gửi khi giao hàng không thành công: Bưu gửi được chuyển hoàn để trả lại cho Khách Hàng khi không phát được cho người nhận hoặc Khách Hàng yêu cầu chuyển hoàn. Khách Hàng phải thanh toán cước phí hoàn trả theo Biểu Phí Dịch Vụ, trừ trường hợp các bên có thỏa thuận khác.
Quy định về xử lý bưu gửi không có người nhận: Đối với bưu gửi mà Người nhận từ chối nhận và Khách Hàng cũng từ chối nhận lại hoặc không thể hoàn trả cho Khách Hàng thì bưu gửi này sẽ được xử lý theo quy định của pháp luật hiện hành về xử lý bưu gửi không có người nhận.
Điều 6. Quy định về nội dung bưu gửi
Quy định về đóng gói bưu gửi
Khách Hàng cam kết và bằng chi phí của mình chịu trách nhiệm gói bọc bưu gửi theo quy định TDLogistics; thông báo và ghi chú các lưu ý bảo quản bưu gửi.
TDLogistics chỉ chấp nhận bưu gửi đã được đóng gói, bảo quản đúng quy chuẩn, quy định của TDLogistics.
TDLogistics không chịu trách nhiệm cho bất kỳ thiệt hại, biến dạng, hư hỏng, hết hạn, hư hỏng, có mùi hôi, bị tràn hoặc bất kỳ sự lỗi nào liên quan đến các sản phẩm trong suốt quá trình giao hàng mà nguyên nhân do việc đóng hàng hoặc gói hàng không đúng cách.
Quy định về vật phẩm, hàng hóa được phép tiếp nhận, vận chuyểnTDLogistics chỉ tiếp nhận, vận chuyển vật phẩm, hàng hóa hợp pháp, đáp ứng đầy đủ các điều kiện vận chuyển theo quy định của pháp luật hiện hành (có hóa đơn, chứng từ, nguồn gốc xuất xứ...). Lưu ý một số hàng hóa không được phép tiếp nhận, vận chuyển như sau:
Vũ khí quân dụng, trang thiết bị, kỹ thuật, khí tài, phương tiện chuyên dùng quân sự, công an; quân trang (bao gồm cả phù hiệu, cấp hiệu, quân hiệu của quân đội, công an), quân dụng cho lực lượng vũ trang
Súng săn và đạn súng săn, vũ khí thể thao, công cụ hỗ trợ
Các chất ma túy và chất kích thích thần kinh; Các loại hóa chất, tiền chất bị cấm
Thực vật, động vật hoang dã (bao gồm cả vật sống và các bộ phận của chúng đã được chế biến) thuộc danh mục điều ước quốc tế mà Việt Nam là thành viên quy định và các loại thực vật, động vật quý hiếm thuộc danh mục cấm khai thác và sử dụng
Hàng hóa buôn lậu, hàng không có chứng từ đi kèm đầy đủ
Thuốc lá điếu, xì gà và các dạng thuốc lá thành phẩm khác nhập lậu
Hàng hóa có điều kiện nhưng không đủ điều kiện vận chuyển
Hàng hóa cồng kềnh, vượt quá kích thước cho phép theo quy định của luật giao thông
Các hàng hóa, tài sản do hành vi vi phạm pháp luật, hành vi phạm tội mà có
Hàng hóa, tài sản có mục đích gửi để tẩu tán; trốn tránh nghĩa vụ theo quy định của pháp luật hiện hành; để thực hiện hành vi phạm tội; vi phạm pháp luật
Các trường hợp TDLogistics được quyền từ chối cung ứng Dịch Vụ
Khách hàng vi phạm pháp luật về vật phẩm, hàng hóa quy định tại mục này bao gồm nhưng không giới hạn việc gửi vật phẩm, hàng hóa bị cấm/hạn chế kinh doanh, vận chuyển; Hàng hóa chưa được đóng gói đầy đủ, Hàng hóa không có đầy đủ hóa đơn - chứng từ kèm theo hàng hóa theo quy định pháp luật
Nội dung bưu gửi được gửi có tính chất dễ bị hư hỏng trong thời gian ngắn
TDLogistics không chịu trách nhiệm về chất lượng của hàng hóa được cung cấp bởi các nhà bán hàng mà TDLogistics vận chuyển.
Các thông tin bắt buộc trên Đơn hàng không đầy đủ hoặc không rõ ràng.
Yêu cầu giao nhận bưu gửi được thực hiện ngoài phạm vi hoặc thời gian cung cấp Dịch Vụ.
TDLogistics có cơ sở hợp lý để nghi ngờ rằng Khách Hàng đã hoặc bằng việc chấp nhận Đơn hàng sẽ vi phạm Điều Khoản Sử Dụng hoặc quy định pháp luật.
Điều 7. Chính sách bảo mật thông tin
TDLogistics được quyền thu thập và xử lý các thông tin cá nhân của Khách hàng khi Khách hàng đăng ký, sử dụng Dịch Vụ. Khách hàng phải cung cấp chính xác và đầy đủ thông tin cá nhân theo yêu cầu hợp lý của TDLogistics. Nếu có bất kỳ thông tin sai lệch nào, TDLogistics sẽ không chịu trách nhiệm trong trường hợp thông tin đó làm ảnh hưởng hoặc hạn chế quyền lợi của Khách Hàng. Nếu các thông tin Khách Hàng cung cấp cho TDLogistics thay đổi, Khách Hàng có trách nhiệm cập nhật chi tiết thay đổi trên Ứng Dụng.
TDLogistics sử dụng thông tin thu thập từ Khách Hàng hoặc do Khách Hàng cung cấp cho một số hoặc tất cả mục đích sau đây:
Tạo thuận lợi cho việc sử dụng Dịch Vụ của các Khách Hàng
Xử lý các Đơn hàng mà Khách Hàng đã tạo thông qua Ứng Dụng
Cập nhật cho Khách Hàng về thời gian giao hàng và cho các mục đích hỗ trợ Khách Hàng
Để gửi cho Khách Hàng các tài liệu tiếp thị và/hoặc quảng cáo về dịch vụ đối tác hoặc để gửi bản tin từ TDLogistics và từ các công ty liên kết
Trong trường hợp ngoại lệ, TDLogistics có thể bị yêu cầu tiết lộ thông tin cá nhân, chẳng hạn như khi có căn cứ cho rằng việc tiết lộ là cần thiết để ngăn ngừa mối đe dọa đến mạng sống hoặc sức khỏe, hoặc vì mục đích thực thi pháp luật hoặc để đáp ứng các yêu cầu pháp lý và theo quy định khác.
Để đảm bảo an toàn và bảo mật trong sử dụng Dịch Vụ, Khách Hàng có trách nhiệm:
Khách Hàng cam kết rằng Khách Hàng sẽ sử dụng Ứng Dụng chỉ cho mục đích sử dụng Dịch Vụ. Khách hàng không được phép lạm dụng hoặc sử dụng Ứng dụng cho các mục đích gian lận, vi phạm pháp luật.
Chỉ có Khách Hàng mới có thể sử dụng tài khoản của mình và phải đảm bảo không cho phép người khác sử dụng danh tính hoặc tài khoản. Khách Hàng không được quyền chuyển giao hoặc chuyển nhượng tài khoản của mình cho bất kỳ các bên nào khác.
Khách Hàng phải giữ mật khẩu tài khoản và mọi thông tin về danh tính mà TDLogistics cung cấp đến Khách Hàng một cách an toàn và bảo mật. Trong trường hợp mật khẩu của Khách Hàng bị tiết lộ, bất kể bằng cách nào, khiến cho tài khoản hoặc danh tính của Khách Hàng bị sử dụng bất hợp pháp hoặc trái phép, thì các Đơn hàng do việc sử dụng bất hợp pháp hoặc trái phép đó vẫn được coi là hợp lệ, trừ khi Khách Hàng thông báo cho TDLogistics về vấn đề đó trước khi Bên thứ 3 thực hiện các Dịch Vụ theo yêu cầu.
Hợp tác và cung cấp thông tin theo yêu cầu của TDLogistics và Cơ quan Nhà nước có thẩm quyền trong quá trình điều tra các trường hợp nghi ngờ phạm pháp, lừa đảo hoặc vi phạm các quy định của Pháp luật có liên quan.
Khách hàng sẽ phải bảo mật và sẽ không lạm dụng thông tin Khách Hàng nhận được từ việc sử dụng Ứng Dụng. Khách Hàng sẽ đối xử với các Bên thứ 3 với sự tôn trọng và sẽ không tiến hành bất kỳ hành vi hoặc hoạt động nào trái pháp luật, đe dọa hoặc quấy rối.
Khi đăng ký sử dụng Dịch Vụ, Khách Hàng đồng ý và thừa nhận rằng TDLogistics được quyền lưu trữ, cập nhật và sử dụng các dữ liệu thông tin cá nhân do Khách Hàng cung cấp, cập nhật phát sinh từ việc Khách Hàng đăng ký, sử dụng Dịch Vụ và đồng ý cho TDLogistics/đối tác hợp tác với TDLogistics sử dụng các dữ liệu này cho các mục đích, bao gồm nhưng không giới hạn: phục vụ Khách Hàng thực hiện các giao dịch và sử dụng dịch vụ do TDLogistics cung cấp, giới thiệu các sản phẩm, dịch vụ của TDLogistics và đối tác phù hợp nhất tới Khách Hàng.
Khách Hàng hiểu và đồng ý rằng việc sử dụng Ứng Dụng của Khách Hàng cũng sẽ phụ thuộc vào Chính Sách Bảo Mật có thể được sửa đổi, bổ sung, cập nhật tùy từng thời điểm. Bằng việc sử dụng Ứng Dụng, Khách Hàng cũng đã đồng ý tuân thủ các yêu cầu của Chính Sách Bảo Mật của TDLogistics.
Điều 8. Sở hữu trí tuệ
TDLogistics là chủ sở hữu duy nhất, độc quyền với các thiết kế, biểu tượng, hình ảnh, logo, ngôn ngữ, nhãn hiệu, tên thương hiệu hoặc bất kỳ phần nào khác của Ứng dụng TDLogistics. Không cá nhân, tổ chức nào được phép sao chép, tái tạo, phân phối, tự ý thay đổi tên gọi, hình ảnh, giao diện và các thành phần liên quan đến thương hiệu sản phẩm của TDLogistics tại bất kỳ đâu, hoặc các hình thức xâm phạm khác. Ứng dụng này được phát triển bởi TDLogistics, tất cả quyền sở hữu trí tuệ liên quan đều được bảo hộ.

Điều 9. Bồi thường thiệt hại
Nguyên tắc bồi thường thiệt hại
Chính sách bồi thường thiệt hại đối với bưu gửi của Khách hàng áp dụng theo các nguyên tắc như sau:

TDLogistics chỉ chịu trách nhiệm bồi thường thiệt hại cho Khách hàng trong trường hợp bưu gửi thực hiện theo Đơn hàng hợp lệ mà bị mất, thất lạc, hư hỏng xảy ra trong quá trình cung ứng Dịch Vụ và lỗi của TDLogistics là nguyên nhân trực tiếp dẫn đến thiệt hại cho Khách Hàng.
Mức bồi thường được xác định dựa trên cơ sở thiệt hại thực tế và mức thiệt hại được tính theo giá thị trường đối với vật phẩm, hàng hóa cùng loại tại địa điểm và thời điểm mà bưu gửi/vật gửi đó được chấp nhận, nhưng không vượt quá mức bồi thường trong trường hợp bưu gửi/vật gửi bị mất hoặc hư hại hoàn toàn.
Không bồi thường thiệt hại gián tiếp hoặc nguồn lợi không thu được do việc cung ứng Dịch Vụ không bảo đảm chất lượng Dịch Vụ mà TDLogistics đã công bố.
Mức bồi thường thiệt hại:
a) Bồi thường thiệt hại đối với hàng hóa bị mất:

Trường hợp Khách hàng sử dụng dịch vụ COD: được bồi thường tối đa bằng 100% số tiền thu hộ (không bao gồm lợi nhuận) nhưng không quá 30 triệu đồng/bưu gửi.
Trường hợp Khách hàng không sử dụng dịch vụ COD:
Đối với Khách hàng cung cấp được chứng từ chứng minh giá trị thiệt hại (hóa đơn tài chính, chứng từ chuyển khoản có xác nhận của ngân hàng): Bồi thường 70% giá trị thiệt hại nhưng tối đa không quá 30 triệu đồng/bưu gửi.
Trường hợp Khách hàng không cung cấp được chứng từ chứng minh giá trị thiệt hại: bồi thường tối đa 04 lần cước (đã bao gồm hoàn trả lại cước dịch vụ đã sử dụng) của dịch vụ đã sử dụng.
b) Bồi thường thiệt hại đối với hàng hóa bị hư hỏng:

Việc bồi thường thiệt hại trong trường hợp bưu gửi bị hư hỏng hoặc tráo đổi một phần được xác định trên cơ sở thiệt hại thực tế, nhưng tối đa không quá 30 triệu đồng/bưu gửi.

Ghi chú: Giá trị bưu gửi được xác định theo (giá trị bồi thường mất hàng hóa) x (% hư hỏng hàng hóa)

c) Thời hạn bồi thường:

Thời hạn bồi thường thiệt hại không quá 30 ngày kể từ ngày các bên lập văn bản xác định trách nhiệm bồi thường thiệt hại.

Điều 10. Miễn trừ trách nhiệm
Khách Hàng đồng ý rằng TDLogistics sẽ được miễn trừ mọi trách nhiệm pháp lý, trách nhiệm đền bù, bồi thường bởi các thiệt hại xảy ra trong các trường hợp sau:

Thiệt hại xảy ra hoàn toàn do lỗi vi phạm Điều Khoản Sử Dụng và/hoặc Hợp đồng (nếu có) của Khách Hàng và/hoặc do đặc tính tự nhiên, khuyết tật vốn có của hàng hóa.
Khách Hàng không tuân thủ các quy định của pháp luật liên quan đến hàng hóa cấm hoặc hạn chế lưu thông, vận chuyển và các quy định khác của pháp luật (bao gồm nhưng không giới hạn bởi trường hợp Hàng hóa không có hóa đơn, chứng từ nguồn gốc xuất xứ; bị kiểm tra, tịch thu hoặc tiêu hủy theo quyết định của cơ quan có thẩm quyền);
Khách Hàng không chứng minh được việc gửi và hư hỏng bưu gửi là do lỗi của TDLogistics;
Bưu gửi đã được giao và Người nhận không có ý kiến khi nhận hàng;
Tổn thất phát sinh do TDLogistics làm đúng theo những chỉ dẫn của Khách Hàng hoặc của người được Khách Hàng ủy quyền;
Việc không thực hiện hoặc thực hiện cẩu thả, bất cẩn, cố ý làm sai, hoặc lừa đối của Khách Hàng (bao gồm nhưng không giới hạn bởi trường hợp việc cung cấp, kê khai thông tin về hàng hóa không đúng hoặc thiếu sót; đóng gói, bao bọc hàng hóa không cẩn thận; thông tin người nhận không đúng hoặc thiếu sót; Khách hàng không có chứng từ chứng minh việc sử dụng dịch vụ);
Bưu gửi vận chuyển vượt quá kích thước, trọng lượng quy định hoặc ngoài thời gian, phạm vi TDLogistics cung ứng Dịch Vụ;
Khách hàng không thực hiện đúng các quy định về khiếu nại, giải quyết tranh chấp theo quy định tại Điều Khoản Sử Dụng này;
Các trường hợp bất khả kháng theo quy định của pháp luật Việt Nam.
Điều 11. Giải quyết khiếu nại
Hình thức khiếu nại:
TDLogistics chịu trách nhiệm tiếp nhận khiếu nại và hỗ trợ Khách Hàng liên quan đến Dịch Vụ được kết nối qua Ứng Dụng. Khi phát sinh khiếu nại, TDLogistics đề cao giải pháp thương lượng, hòa giải giữa các bên. Khách Hàng có thể thực hiện khiếu nại theo một trong các hình thức sau:

Gọi điện thoại đến số tổng đài hỗ trợ khách hàng.
Gửi thư điện tử đến email hỗ trợ khách hàng.
Gửi khiếu nại từ Ứng dụng TDLogistics.
Thời hiệu khiếu nại và giải quyết khiếu nại
a) Thời hiệu khiếu nại:

Khách hàng được quyền khiếu nại trong thời hiệu:

06 tháng, kể từ ngày kết thúc thời gian toàn trình của bưu gửi đối với khiếu nại về việc mất bưu gửi, chậm phát bưu gửi chậm so với thời gian toàn trình đã công bố;
01 tháng, kể từ ngày bưu gửi được phát cho Người nhận đối với khiếu nại về việc bưu gửi bị suy suyển, hư hỏng, về giá cước và các nội dung khác có liên quan trực tiếp đến bưu gửi.
b) Thời hạn giải quyết khiếu nại (kể từ ngày TDLogistics nhận được khiếu nại):

Không quá 07 (bảy) ngày làm việc.
Trường hợp đặc biệt, không quá 02 (hai) tháng đối với dịch vụ bưu chính trong nước và không quá 03 tháng đối với dịch vụ bưu chính quốc tế (theo quy định của Luật bưu chính).
Việc giải quyết tranh chấp, khiếu nại phát sinh theo quy định của pháp luật Việt Nam.
Điều 12. Quyền và nghĩa vụ của Khách hàng
1. Quyền của Khách hàng:
Được cung cấp đầy đủ thông tin liên quan đến quy trình cung ứng Dịch Vụ;
Được đảm bảo bí mật thông tin, an toàn đối với bưu gửi trong quá trình sử dụng Dịch Vụ;
Được quyền yêu cầu giải quyết khiếu nại hợp lệ về Dịch Vụ đã sử dụng theo pháp luật hiện hành;
Được bồi thường thiệt hại theo Điều Khoản Sử Dụng này;
Các quyền khác theo quy định của pháp luật.
2. Nghĩa vụ của Khách Hàng:
Thực hiện đúng các quy trình, hướng dẫn giao dịch; cung cấp đầy đủ, xác thực, kịp thời các thông tin theo yêu cầu khi đăng ký sử dụng Ứng Dụng và trong suốt quá trình sử dụng Dịch Vụ.
Không được phép làm tổn hại, chỉnh sửa Ứng Dụng hoặc cố tình đe dọa, chỉnh sửa Ứng Dụng bằng bất kỳ cách nào. Hoàn toàn chịu trách nhiệm và bồi thường thiệt hại xảy ra nếu không thực hiện đúng, đầy đủ yêu cầu này;
Không gửi hàng cấm gửi và thực hiện đầy đủ quy định đảm bảo an ninh, an toàn bưu gửi (gói bọc, niêm phong, dán nhãn lưu ý...) theo quy định của TDLogistics và pháp luật hiện hành;
Khai báo trung thực nội dung bưu gửi, chịu trách nhiệm cung cấp đầy đủ hóa đơn, chứng từ đi kèm khi sử dụng Dịch Vụ và/hoặc yêu cầu của cơ quan nhà nước có thẩm quyền;
Có trách nhiệm làm việc với cơ quan Nhà nước có thẩm quyền trong trường hợp bưu gửi bị thu giữ do thiếu chứng từ hoặc cần làm rõ chứng từ và hàng hóa; Thực hiện nộp phạt theo quyết định của cơ quan nhà nước có thẩm quyền khi có yêu cầu;
Chịu trách nhiệm thanh toán cước phí dịch vụ và các khoản phí dịch vụ giá trị gia tăng khác theo như đã thỏa thuận;
Trong trường hợp Khách Hàng có hành vi vi phạm hoặc TDLogistics có căn cứ nghi ngờ Khách hàng vi phạm Điều Khoản Sử Dụng hoặc có hành vi vi phạm pháp luật thì TDLogistics có quyền ngay lập tức khóa tài khoản ứng dụng của Khách Hàng mà không cần phải lấy ý kiến hay được sự đồng ý của Khách Hàng hoặc bên thứ ba nào khác;
Cung cấp đầy đủ các chỉ dẫn liên quan đến bưu gửi; thông tin liên quan đến Người gửi, Người nhận trên bưu gửi;
Chịu trách nhiệm về mọi thông tin liên quan đến người nhận mà Khách Hàng cung cấp để thực hiện Đơn hàng. Trường hợp xảy ra sai sót về thông tin Người nhận hoặc bưu gửi không đúng yêu cầu của Người nhận do lỗi của Khách hàng thì Khách hàng có trách nhiệm tự giải quyết với người nhận, đồng thời TDLogistics vẫn tính cước phí Dịch vụ đối với Đơn hàng trên dựa trên lộ trình đã thực hiện;
Chịu trách nhiệm bồi thường thiệt hại cho TDLogistics toàn bộ thiệt hại thực tế xảy ra theo quy định của pháp luật khi vi phạm bất cứ điều khoản nào theo Điều kiện sử dụng này và/hoặc các văn bản, quy định khác mà TDLogistics công bố;
Các nghĩa vụ khác theo quy định của pháp luật và/hoặc thỏa thuận bằng văn bản giữa Khách hàng và TDLogistics.
Điều 13. Quyền và nghĩa vụ của TDLogistics
1. Quyền của TDLogistics:
Yêu cầu Khách Hàng cung cấp thông tin theo quy định pháp luật khi đăng ký sử dụng Ứng Dụng để cung ứng Dịch Vụ.
Yêu cầu Khách Hàng cho kiểm tra bưu gửi trong trường hợp có dấu hiệu cho thấy bưu gửi không đúng, đủ tiêu chuẩn, nghi ngờ hàng cấm, hàng gian lận thương mại hoặc theo yêu cầu của cơ quan Nhà nước có thẩm quyền.
Được miễn trừ trách nhiệm theo Điều 10 của Điều khoản sử dụng này;
Được chấm dứt/từ chối/tạm dừng cung cấp dịch vụ mà không cần phải báo trước cho Khách Hàng khi Khách Hàng không tuân thủ các điều kiện, điều khoản quy định tại Điều Khoản Sử Dụng này;
Sử dụng thông tin giao dịch giữa Khách Hàng nhằm quảng bá cho thương hiệu, uy tín của Ứng Dụng, trừ trường hợp Khách Hàng từ chối bằng văn bản;
Được Khách hàng bồi thường thiệt hại theo quy định của Điều Khoản Sử Dụng này;
Quyền thay đổi biểu giá, các loại Dịch Vụ trong quá trình cung ứng Dịch Vụ;
Các quyền khác theo quy định của pháp luật.
2. Nghĩa vụ:
Cung cấp đúng, đầy đủ thông tin về dịch vụ cung ứng, cước dịch vụ đã cung ứng cho Khách Hàng;
Đảm bảo chất lượng dịch vụ đã cam kết với Khách Hàng;
Tiếp nhận và giải quyết khiếu nại về dịch vụ của Khách Hàng;
Chuyển hoàn bưu gửi để trả lại cho Khách Hàng khi không phát được cho Người nhận, trừ trường hợp Khách Hàng có yêu cầu khác;
Điều 14. Các trường hợp bất khả kháng
Những trường hợp được coi là sự kiện bất khả kháng bao gồm nhưng không hạn chế như thiên tai, hỏa hoạn, lũ lụt, động đất, tai nạn, thảm họa, hạn chế về dịch bệnh, nhiễm hạt nhân hoặc phóng xạ, chiến tranh, nội chiến, khởi nghĩa, đình công hoặc bạo loạn... dẫn tới việc không cung cấp được dịch vụ tới Khách hàng thì TDLogistics sẽ phải nhanh chóng thông báo cho Khách hàng qua các phương tiện truyền thông: trang thông tin điện tử của TDLogistics, tổng đài hỗ trợ, tin nhắn SMS, quầy giao dịch và các phương tiện phù hợp khác.
TDLogistics được miễn trừ trách nhiệm trong trường hợp xảy ra sự kiện bất khả kháng nằm ngoài khả năng khắc phục của TDLogistics và các sự cố/sự kiện phát sinh nằm ngoài phạm vi kiểm soát, phòng ngừa và dự kiến của TDLogistics dẫn đến việc không thể nhận, xử lý hoặc thực hiện các Đơn hàng của Khách hàng và/hoặc dẫn đến thiệt hại cho Khách hàng bao gồm nhưng không giới hạn như:
Các sự cố phát sinh từ bên thứ ba cung ứng dịch vụ hạ tầng (điện, đường truyền Internet...) và bất kỳ bên thứ ba nào khác cung cấp dịch vụ cho hoạt động cung cấp Dịch vụ của Ứng dụng.
Hệ thống đường truyền giữa TDLogistics và đối tác gặp sự cố, bị thâm nhập trái phép.
Hệ thống thông tin, thiết bị của TDLogistics, thiết bị sử dụng Dịch vụ của Khách hàng gặp sự cố do bị tấn công, nhiễm virus hoặc bị ảnh hưởng của những sự cố ngoài ý muốn khác.
Các trường hợp khác ngoài kiểm soát của TDLogistics.
Điều 15. Điều khoản thi hành
Khách hàng đã đọc, hiểu, nhất trí và cam kết thực hiện nghiêm túc các điều khoản, điều kiện nêu tại Điều khoản sử dụng này. Các vấn đề chưa được quy định, các Bên thống nhất thực hiện theo quy định của pháp luật, hướng dẫn của cơ quan Nhà nước có thẩm quyền và/hoặc các cam kết/thỏa thuận có hiệu lực khác giữa các Bên.
Các điều khoản khác:
Khách hàng không được chuyển giao hoặc chuyển nhượng các quyền của Khách hàng theo Điều khoản sử dụng, mà không có sự chấp thuận bằng văn bản.
Nếu bất kỳ điều khoản nào của Điều khoản sử dụng này bị coi là bất hợp pháp, vô hiệu hoặc không thể thi hành, điều khoản này hoặc một phần của nó, theo quy định pháp luật, sẽ được coi là không tạo thành một phần của Điều khoản sử dụng này nhưng tính hợp pháp, tính hợp lệ hoặc tính thực thi của phần còn lại của Điều khoản sử dụng này sẽ không bị ảnh hưởng.
Điều khoản sử dụng này được điều chỉnh và được giải thích theo quy định của pháp luật Cộng Hòa Xã Hội Chủ Nghĩa Việt Nam. Các tranh chấp phát sinh từ việc sử dụng Dịch vụ qua Ứng dụng TDLogistics thì các Bên sẽ chủ động giải quyết trên cơ sở thương lượng, các bên cùng có lợi. Trường hợp tranh chấp không giải quyết được, tranh chấp sẽ được giải quyết bởi Tòa án có thẩm quyền theo quy định pháp luật.
Điều khoản sử dụng có thể được bổ sung, chỉnh sửa và thay đổi từng thời điểm. TDLogistics sẽ thông báo cho Khách hàng thông qua Ứng dụng và/hoặc Email về các bổ sung, chỉnh sửa và/hoặc thay đổi của Điều khoản sử dụng. Việc tiếp tục sử dụng Ứng dụng sau khi nhận được thông báo này sẽ tạo thành sự đồng ý và chấp nhận pháp lý đối với các bổ sung, chỉnh sửa, và/hoặc thay đổi.
Điều Khoản Sử Dụng này có hiệu lực kể từ ngày 01/08/2021.
        """,
      },
      {
        'id': 'private',
        'title': 'Chính sách bảo mật thông tin',
        'icon': Icons.privacy_tip_outlined,
        'type': DocumentType.text,
        'data': """
Chính sách bảo mật
Cập nhật lần cuối: 08/02/2023

1. Mục đích và phạm vi thu thập
TDLogistics chỉ thu thập các thông tin cá nhân cần thiết như họ tên, số điện thoại, email, vị trí của người dùng nhằm mục đích:

Liên hệ xác nhận khi khách hàng đăng ký sử dụng dịch vụ
Hỗ trợ khách hàng trong quá trình sử dụng dịch vụ
TDLogistics không lưu giữ thông tin tài khoản ngân hàng hoặc bất kỳ thông tin nhạy cảm nào khác của người dùng.

2. Phạm vi sử dụng thông tin
Thông tin cá nhân được sử dụng để:

Cung cấp dịch vụ đến khách hàng
Gửi thông báo về hoạt động của khách hàng với TDLogistics
Liên hệ và giải quyết các trường hợp đặc biệt
TDLogistics cam kết không sử dụng thông tin cá nhân ngoài mục đích phục vụ khách hàng, trừ khi có yêu cầu từ cơ quan pháp luật.

3. Thời gian lưu trữ thông tin
Thông tin cá nhân được lưu trữ cho đến khi có yêu cầu hủy bỏ từ phía khách hàng hoặc TDLogistics không còn mục đích sử dụng.

4. Đơn vị thu thập và quản lý thông tin
Công ty TDLogistics

Địa chỉ: 83 Đinh Tiên Hoàng, P1, Quận Bình Thạnh, Tp Hồ Chí Minh, Việt Nam

Hotline: +84 977678999

Email: info@tdtel.vn

5. Quyền của khách hàng
Khách hàng có quyền kiểm tra, cập nhật, chỉnh sửa hoặc yêu cầu hủy bỏ thông tin cá nhân của mình bằng cách liên hệ trực tiếp qua email hoặc hotline.

6. Cam kết bảo mật
TDLogistics cam kết bảo mật tuyệt đối thông tin cá nhân của khách hàng, không tiết lộ cho bên thứ ba nếu không có sự đồng ý từ khách hàng, trừ trường hợp pháp luật yêu cầu.

Trong trường hợp xảy ra sự cố rò rỉ thông tin, TDLogistics sẽ thông báo kịp thời đến khách hàng và cơ quan chức năng để phối hợp xử lý.

7. Khiếu nại
Nếu khách hàng phát hiện thông tin cá nhân bị sử dụng sai mục đích, xin vui lòng gửi email đến info@tdtel.vn để được xử lý trong vòng 24 giờ.

8. Phương thức mã hóa và bảo vệ dữ liệu
Tất cả dữ liệu cá nhân do TDLogistics thu thập đều được mã hóa khi truyền tải qua Internet bằng các giao thức bảo mật như HTTPS.

Chúng tôi áp dụng các biện pháp kỹ thuật và tổ chức phù hợp để bảo vệ thông tin khỏi truy cập trái phép, thay đổi, tiết lộ hoặc phá hủy.

9. Phương thức tạo tài khoản và xác thực
Người dùng có thể tạo tài khoản bằng email và mật khẩu hoặc thông qua phương thức xác thực khác như mã OTP. TDLogistics không sử dụng các hình thức xác thực sinh trắc học.

10. Yêu cầu xóa dữ liệu cá nhân
Nếu bạn muốn yêu cầu xóa một phần hoặc toàn bộ dữ liệu cá nhân mà không cần xóa tài khoản, vui lòng liên hệ qua email:

info@tdtel.vn
11. Liên kết yêu cầu xóa tài khoản hoặc dữ liệu
Nếu bạn muốn yêu cầu xóa tài khoản và toàn bộ dữ liệu cá nhân, vui lòng nhấn vào liên kết dưới đây:

Gửi yêu cầu xóa tài khoản qua email
        """,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khoản & Giấy tờ",
            style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.separated(
        itemCount: documents.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return ListTile(
            leading: Icon(doc['icon'] as IconData, color: Colors.grey.shade700),
            title: Text(doc['title'] as String,
                style: const TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final type = doc['type'] as DocumentType;
              final title = doc['title'] as String;
              final id = doc['id'] as String;

              switch (type) {
                case DocumentType.multiImage:
                  final imageUrls = doc['data'] as List<String>;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MultiImageDisplayPage(
                              title: title, imageUrls: imageUrls)));
                  break;
                case DocumentType.text:
                  if (id == 'private') {
                    final content = doc['data'] as String;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => InfoDisplayPage(
                                title: title, content: content)));
                  } else if (id == 'business_license') {
                    _showBusinessLicensePopup(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AboutServicePage()),
                    );
                  }
                  break;
                case DocumentType.placeholder:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Nội dung đang được cập nhật.')),
                  );
                  break;
              }
            },
          );
        },
      ),
    );
  }

  void _showBusinessLicensePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Giúp dialog co lại vừa với nội dung
              children: [
                // 1. Logo công ty
                Image.asset('lib/assets/logo.png',
                    height: 60), // Đảm bảo bạn có logo ở đường dẫn này
                const SizedBox(height: 16),

                // 2. Tên giấy phép
                const Text(
                  'GIẤY CHỨNG NHẬN ĐĂNG KÝ DOANH NGHIỆP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CÔNG TY CỔ PHẦN', // Loại hình công ty
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Divider(height: 32, thickness: 1),

                // 3. Các thông tin chi tiết
                _buildInfoRow(
                    'Số GPKD:', '0123456789'), // <-- THAY THÔNG TIN CỦA BẠN
                const SizedBox(height: 12),
                _buildInfoRow('Nơi cấp:',
                    'Sở Kế hoạch và Đầu tư TP. Hồ Chí Minh'), // <-- THAY THÔNG TIN CỦA BẠN
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Ngày cấp:', '01/01/2020'), // <-- THAY THÔNG TIN CỦA BẠN
                const SizedBox(height: 32),

                // Nút đóng
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class MultiImageDisplayPage extends StatefulWidget {
  final String title;
  final List<String> imageUrls;

  const MultiImageDisplayPage({
    super.key,
    required this.title,
    required this.imageUrls,
  });

  @override
  State<MultiImageDisplayPage> createState() => _MultiImageDisplayPageState();
}

class _MultiImageDisplayPageState extends State<MultiImageDisplayPage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black87,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                // Cho phép người dùng phóng to, thu nhỏ ảnh
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error, color: Colors.red)),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          // Hiển thị số trang hiện tại
          if (widget.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Trang ${_currentPage + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
