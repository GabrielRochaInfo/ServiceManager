import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service.dart';
import '../repositories/client_repository.dart';
import '../models/client.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  final ClientRepository _clientRepo = ClientRepository();

  ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  Color _statusColor() {
    switch (service.status) {
      case 'Concluído':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _equipmentIcon() {
    final equipment = service.equipment.toLowerCase();

    if (equipment.contains('notebook') ||
        equipment.contains('laptop')) {
      return Icons.laptop_mac_rounded;
    }

    if (equipment.contains('pc') ||
        equipment.contains('computador')) {
      return Icons.computer_rounded;
    }

    if (equipment.contains('iphone') ||
        equipment.contains('celular') ||
        equipment.contains('smartphone')) {
      return Icons.smartphone_rounded;
    }

    if (equipment.contains('tablet')) {
      return Icons.tablet_android_rounded;
    }

    return Icons.build_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final statusColor = _statusColor();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Card(
        elevation: 5,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _equipmentIcon(),
                        color: statusColor,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.equipment,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),

                          if (service.brand != null &&
                              service.brand!.isNotEmpty)
                            Text(
                              service.brand!,
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: Text(
                        service.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                FutureBuilder<Client?>(
                  future: _clientRepo.getClientById(
                    service.clientId,
                  ),
                  builder: (context, snapshot) {
                    String clientName =
                        'Carregando cliente...';

                    if (snapshot.hasData &&
                        snapshot.data != null) {
                      clientName =
                          snapshot.data!.name;
                    }

                    if (snapshot.connectionState ==
                            ConnectionState.done &&
                        !snapshot.hasData) {
                      clientName =
                          'Cliente não encontrado';
                    }

                    return Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            clientName,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.serviceDescription,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          currencyFormat.format(
                            service.value,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Data',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          service.createdAt
                              .split('T')
                              .first,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}