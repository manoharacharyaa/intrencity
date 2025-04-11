import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class MySpacesPage extends StatelessWidget {
  const MySpacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spaces'),
      ),
      body: StreamBuilder(
        stream: context.read<SpaceAdminViewmodel>().getMySpacesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final mySpaces = snapshot.data ?? [];

          if (mySpaces.isEmpty) {
            return const Center(child: Text('You Don\'t Have Any Spaces'));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: mySpaces.length,
            itemBuilder: (context, index) {
              final mySpace = mySpaces[index];
              return SmoothContainer(
                onTap: () {
                  context.push(
                    '/admin-parking-page',
                    extra: {
                      'spaceId': mySpace.docId,
                      'docId': mySpace.docId,
                    },
                  );
                },
                color: textFieldGrey,
                horizontalPadding: 12,
                verticalPadding: 10,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  spacing: 20,
                  children: [
                    SmoothContainer(
                      cornerRadius: 12,
                      height: 100,
                      width: 100,
                      color: Colors.blueGrey,
                      child: Image.network(
                        mySpace.spaceThumbnail[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      child: Text(
                        mySpace.spaceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded)
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
