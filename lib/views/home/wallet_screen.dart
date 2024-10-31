import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final List<Map<String, dynamic>> favorites = [
    {
      'name': 'Tron (TRX)',
      'symbol': 'TRX',
      'amount': '\$456.7',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Ethereum (ETH)',
      'symbol': 'ETH',
      'amount': '\$486.7',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (1).png',
    },
  ];

  final List<Map<String, dynamic>> cryptoList = [
    {
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'price': '\$3,676.76',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (2).png',
    },
    {
      'name': 'United States Dollar',
      'symbol': 'USDT',
      'price': '\$3,676.76',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (3).png',
    },
    {
      'name': 'Tron',
      'symbol': 'TRX',
      'price': '\$3,676.76',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Litecoin',
      'symbol': 'LTC',
      'price': '\$3,676.76',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (4).png',
    },
  ];

  // Add state variables for filter selections
  final Map<String, bool> _filterSelections = {
    'All Crypto': true,
    'Winners': false,
    'Losers': false,
    'Newest': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hey Jason!',
                    style: AppTextStyles.heading.copyWith(fontSize: 30),
                  ),
                  Row(
                    children: [
                     SvgPicture.asset('assets/icons/Search.svg', color: AppColors.text,),
                     SizedBox(width: 10,),
                     Image.asset('assets/icons/ion_notifications.png', color: AppColors.text,),
                     SizedBox(width: 10,),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/icons/Photo by Brooke Cagle.png'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E4E6B), Color(0xFF3D2A54)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '↑ 23.5%',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'USD',
                                style: TextStyle(color: AppColors.text),
                              ),
                              Icon(Icons.keyboard_arrow_down, color: AppColors.text),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$20,456.23',
                      style: AppTextStyles.heading.copyWith(fontSize: 36),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Send/Receive Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send', style: AppTextStyles.body2,),
                            const Icon(Icons.arrow_upward, size: 16, color: AppColors.white,),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Text('Receive',style: AppTextStyles.body2,),
                            Icon(Icons.arrow_downward, size: 16, color: AppColors.white,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Favorites Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit'),
                  ),
                ],
              ),

              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            favorites[index]['icon'],
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                favorites[index]['amount'],
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                favorites[index]['change'],
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Crypto Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crypto',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),

              // Updated Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _filterSelections.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(entry.key),
                        selected: entry.value,
                        onSelected: (bool selected) {
                          if (selected) { // Only handle selection, not deselection
                            setState(() {
                              // First set all to false
                              _filterSelections.forEach((key, value) {
                                _filterSelections[key] = false;
                              });
                              // Then set the selected one to true
                              _filterSelections[entry.key] = true;
                            });
                          }
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: Colors.black,
                        showCheckmark: true,
                        labelStyle: TextStyle(
                          color: entry.value ? Colors.black : AppColors.textSecondary,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Crypto List
              Expanded(
                child: ListView.builder(
                  itemCount: cryptoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.asset(
                        cryptoList[index]['icon'],
                        width: 40,
                        height: 40,
                      ),
                      title: Text(
                        cryptoList[index]['name'],
                        style: const TextStyle(color: AppColors.text),
                      ),
                      subtitle: Text(
                        cryptoList[index]['symbol'],
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            cryptoList[index]['price'],
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cryptoList[index]['change'],
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}