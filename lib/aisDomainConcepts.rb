
module AisDomainConcepts
  
  MessageType = {
    0 => "Unknown",
    1 => "Position Report Class A",
    2 => "Position Report Class A (Assigned Schedule)",
    3 => "Position Report Class A (Response to interrogation)",
    4 => "Base Station Report",
    5 => "Ship and Voyage Data",
    6 => "Addressed Binary Message",
    7 => "Binary Acknowledge",
    8 => "Binary Broadcast Message",
    9 => "Standard SAR Aircraft Position Report",
    10 => "UTC and Date Inquiry",
    11 => "UTC and Date Response",
    12 => "Addressed Safety Related Message",
    13 => "Safety Related Acknowledge",
    14 => "Safety Related Broadcast Message",
    15 => "Interrogation",
    16 => "Assigned Mode Command",
    17 => "GNSS Binary Broadcast Message",
    18 => "Standard Class B CS Position Report",
    19 => "Extended Class B Equipment Position",
    20 => "Data Link Management",
    21 => "Aid-to-Navigation Report",
    22 => "Channel Management",
    23 => "Group Assignment Command",
    24 => "Class B CS Static Data Report",
    25 => "Binary Message, Single Slot",
    26 => "Binary Message, Multiple Slot",
    27 => "Position Report for Long-range Applications"
  }
  MessageType.default = 0

  VesselType = {
    0  => 'Not available',
    (1..19)  => 'Reserved for future use',
    (20..29) => 'Wing in ground',
    30 => 'Fishing',
    31 => 'Towing',
    32 => 'Towing: length > 200 m or breadth > 25 m',
    33 => 'Dredging or underwater operations',
    34 => 'Diving operations',
    35 => 'Military operations',
    36 => 'Sailing',
    37 => 'Pleasure craft',
    (38..39) => 'Reserved for future use',
    (40..49) => 'High speed craft',
    50 => 'Pilot vessel',
    51 => 'Search and rescue vessel',
    52 => 'Tug',
    53 => 'Port tender',
    54 => 'Anti-pollution equipment',
    55 => 'Law enforcement',
    (56..57) => 'Local vessel',
    58 => 'Medical transport',
    59 => 'Non-combat ship according to RR resolution 18',
    (60..69) => 'Passenger',
    (70..79) => 'Cargo',
    (80..89) => 'Tanker',
    (90..99) => 'Other'
  }
  VesselType.default = 0

  NavigationStatus = {
    0  => 'Under way using engine',
    1  => 'At anchor',
    2  => 'Not under command',
    3  => 'Restricted manoeuverability',
    4  => 'Constrained by her draught',
    5  => 'Moored',
    6  => 'Aground',
    7  => 'Engaged in fishing',
    8  => 'Under way sailing',
    (9..14)  => 'Reserved for future use',
    15 => 'Not defined (default)'
  }
  NavigationStatus.default = 15

end # module AisDomainConcepts
