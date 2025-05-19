import 'package:flutter/material.dart';
import 'package:flutter_application_1/shopping_listPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          onPageChanged: (index){
            setState(() => isLastPage = index == 2);
          },
          controller: controller,
          children: [
            buildPage(
              color: Colors.black,
              urlImage: 'assets/Gemini_Generated_Image_mb4lfkmb4lfkmb4l.jpeg',
              title: "Smarter Shopping Lists",
              subtitle: "Create lists, add items, and set dates — all in one place.",
            ),
            buildPage(
              color: Colors.black,
              urlImage: 'assets/Gemini_Generated_Image_uicei0uicei0uice.jpeg',
              title: "Stay Organized, Effortlessly",
              subtitle: "View today’s items, upcoming ones, and everything else — sorted for clarity",
            ),
            buildPage(
              color: Colors.black,
              urlImage: 'assets/Gemini_Generated_Image_98o0o798o0o798o0.jpeg',
              title: "Track What You’ve Bought",
              subtitle: "Check off items as you go, and review your shopping history anytime.",
            ),
          ]
        ),
      ),
      bottomSheet:Container(
      color: Colors.black,
      child: isLastPage
        ? TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
          ),
          backgroundColor: Colors.purple.shade800,
          minimumSize: const Size.fromHeight(80),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 24),
         ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('showHome', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ShoppingListPage(),
            )
          );
        },
      )
      : Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () => controller.jumpToPage(2),
                child: const Text(
                    "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                )
            ),
            Center(
              child: SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                effect: WormEffect(
                  spacing: 16,
                  dotColor: Colors.grey.shade700,
                  activeDotColor: Colors.purple.shade400,

                ),
                onDotClicked: (index) => controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn
                ),
              ),
            ),
            TextButton(
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
                onPressed: ()=> controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut
                )
            )
          ],
        ),
      )
      )
    );
  }
}
Widget buildPage({
  required Color color,
  required String urlImage,
  required String title,
  required String subtitle
}) => Container(
  color: color,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const SizedBox(height: 50),
      Image.asset(
        urlImage,
        height: 350,
        fit: BoxFit.cover,
      ),
      const SizedBox(height: 50),
      Text(
        title,
          key: ValueKey(title), // ensures animation only triggers when text changes
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold
          )
        ),
      const SizedBox(height: 24),
      Container(
            padding: const EdgeInsets.symmetric(horizontal:10 ),
            child: Text(
                subtitle,
              style:  TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.4
                ),
              ),
      )
    ]
  )
);