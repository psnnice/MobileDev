import 'package:flutter/material.dart';
import 'BasePage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the height of the screen
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void showImageDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: screenWidth,
                  height: screenHeight * 0.75, // Set height to 75% of screen height
                  child: InteractiveViewer(
                    child: Image.asset('assets/upmap.jpg'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

return BasePage(
  body: Container(
    color: const Color(0xFFDBE4EB), // เปลี่ยนสีพื้นหลังเป็น DBE4EB
    child: Center(
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                showImageDialog(context);
              },
              child: Image(
                image: const AssetImage('assets/upmap.jpg'),
                width: screenWidth * 1, // Set width to 75% of screen width
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(7),
              color: const Color(0xFFC0D3E0),
              child: ListTile(
                leading: const Icon(Icons.article,
                size: 40,
                color: Color(0xFF8D38C9),
                ),
                title: const Text('News'),
                subtitle: const Text(
                  'ข่าวสารประชาสัมพันธ์และกิจกรรม ภายในมหาวิทยาลัยพะเยา',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/News');
                },
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(7),
              color: const Color(0xFFC0D3E0),
              child: ListTile(
                leading: const Icon(Icons.directions_bus,
                size: 40,
                color: Color(0xFF8D38C9),),
                title: const Text('Bus'),
                subtitle: const Text(
                  'แสดงการเดินรถของรถเมล์ภายในมหาวิทยาลัยพะเยา เเบบเรียลไทม์',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/Bus');
                },
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(7),
              color: const Color(0xFFC0D3E0),
              child: ListTile(
                leading: const Icon(Icons.map,
                size: 40,
                color: Color(0xFF8D38C9),),
                title: const Text('Route Map'),
                subtitle: const Text(
                  'แสดงเส้นทางการเดินรถของรถเมล์ภายในมหาวิทยาลัยพะเยา',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/Map');
                },
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(7),
              color: const Color(0xFFC0D3E0),
              child: ListTile(
                leading: const Icon(Icons.contact_mail,
                size: 40,
                color: Color(0xFF8D38C9),),
                title: const Text('Contact'),
                subtitle: const Text(
                  'ช่องทางการติดต่อภายในมหาวิทยาลัยพะเยา เบื้องต้น',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/Contact');
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
  index: 2, // เพิ่ม index ที่จำเป็น
);
  }
}