// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. (https://github.com/efortuna/dwmpr/blob/master/LICENSE)

class Repository {
  // ORIGINAL CHROMIUM AUTHOR CODE
  final String name;
  //final String url;

  // NON-CHROMIUM AUTHOR CODE
  final String nameWithOwner;

  Repository(this.name, this.nameWithOwner);
  
  String toString() => 'Repository: $nameWithOwner';


  // ORIGINAL CHROMIUM AUTHOR CODE NOT BEING USED
  // final String organization;
  // final int starCount;

  // Repository(this.name, this.url, this.starCount, this.organization);

  // String toString() => '$name, $url, $starCount';
}