import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/responsive.dart';

Widget buildImage(String? image, BuildContext context, String accessToken){
  if(image == null){
    return  CircleAvatar(
      backgroundImage: AssetImage("assets/images/v1.jpg"),
      radius: 24,
    );
  }else{
    return Container(
        width: Responsive.responsiveValue(context, mobile: 50, tablet: 80),
        height:Responsive.responsiveValue(context, mobile: 50, tablet:  80),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            httpHeaders: {'Authorization': 'Bearer $accessToken'},
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.person),
          ),
        )
    );
  }
}