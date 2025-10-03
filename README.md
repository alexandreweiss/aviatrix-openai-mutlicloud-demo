# Aviatrix OpenAI Multi-Cloud Demo

This Terraform deployment creates a multi-cloud infrastructure demo showcasing OpenAI integration with Azure AI Search using Aviatrix networking.

## Architecture Overview
![Packet Walk Diagram](image/oai-packet-walk.png)

**Packet Walk Explanation:**

1. **User Request:** The user accesses the OpenAI chat application hosted on the EC2 instance in the AWS Spoke VPC.
2. **Application Processing:** The application processes the request and prepares to query Azure Open AI and in turn, Azure AI Search.
3. **DNS Resolution:** The EC2 instance uses the custom DNS resolver to resolve Azure service endpoints privately.
4. **Aviatrix Transit:** The request traverses the Aviatrix Spoke Gateway to the Transit Gateway, enabling secure cross-cloud routing.
5. **Azure AI Search Query:** The request exits AWS via the Aviatrix Azure Transit Gateway over IPSec tunnel and reaches Azure AI Search over private connectivity.
6. **Response Path:** Azure AI Search and Open AI returns results via the same secure path, back to the EC2 instance.
7. **User Response:** The application sends the processed response to the user.

This packet walk demonstrates secure, private, and automated cross-cloud connectivity between AWS and Azure using Aviatrix networking for private endpoint access and private DNS resolution.

The deployment provisions:

1. **AWS Transit Gateway** - Central hub for network connectivity
2. **AWS Spoke VPC** - Application VPC with OpenAI chat application
3. **EC2 Instance** - Ubuntu server hosting the Microsoft OpenAI sample application
4. **Custom DNS Configuration** - Points to private DNS resolver for cross-cloud connectivity
5. **Security Groups** - Network security for internal and public access

## Components

### Application Stack

The EC2 instance is automatically configured with:

- **Microsoft OpenAI Sample App**: Cloned from [sample-app-aoai-chatGPT](https://github.com/microsoft/sample-app-aoai-chatGPT)
- **Python Environment**: Python 3 with venv and pip for application dependencies
- **Node.js**: NPM for frontend dependencies
- **Rust/Cargo**: For building embedding tools
- **SSL Certificate**: Self-signed certificate for HTTPS. Check the domain name to use in the ouput.

### Azure AI Search Integration

Pre-configured JSON schemas for:

- **Search Index**: Vector search capabilities with 1536-dimension embeddings
- **Indexer**: Content extraction and metadata processing
- **Semantic Search**: Enhanced search with BM25 similarity and HNSW algorithm

### VPC, VNET and Gateways10.52

- **One vnet on Azure**: hosts all the AI elements and the storage account used as the source of data for RAG and an Aviatrix Spoke gateway connecting AI services privately to rest of the network,
- **One VPC on AWS**: hosts the AWS EC2 instance running the Python Chat GPT demo application and an Aviatrix Spoke gateway connecting back to Azure and AI services privately
- **A transit per CSP region**: provides the hub in that multi-cloud/region hub and spoke architecture

## Security

### DNS Security

- Custom DNS configuration bypasses public DNS
- Points to private Azure DNS resolver for secure name resolution across clouds.
- Enables private cross-cloud connectivity for DNS requests and Open AI access.

## Required Variables

```hcl

controller_fqdn : contains the FQDN or IP of your Aviatrix Controller for Terraform to access it.
admin_username : Aviatrix Controller admin username (default is admin).
admin_password : Password of the admin user above.
aws_account : the name of the Cloud Account corresponding to your AWS account you want to deploy the Application EC2 VM to.
azure_account : the name of the Cloud Account corresponding to your Azure Subscription you want to deploy AI resources to.
dns_zone_name : if you want to publish you chatbot under your own Azure DNS zone, type here the domain name of it. (default to aviatrix.local)
dns_prefix : Used to concatenate with dns zone name and gives you the full chat bot FQDN (default to chat.aviatrix.local)
ssh_key_name : you can provide the name of the AWS Key pair already existing in your account. Otherwise, if not provided, it will create on and output it on this module folder. BE CAREFUL to store this private key securely.

```
## Deployment

If you use Terraform cloud, you can keep the below section in the versions.tf file updating with your own organization name and workspace name.

```hcl
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-oai-01"
    }
  }
```

Otherwise, comment it out.

> [!WARNING]
> The account your are using to deploy this code must be able to assign or delete roles on the AI services (owner is an example but can also be "Role Based Access Control Administrator")

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd aviatrix-openai-mutlicloud-demo
   ```

2. **Configure Variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan Deployment**:
   ```bash
   terraform plan
   ```

5. **Apply Configuration**:
   ```bash
   terraform apply
   ```

## Post-Deployment

### Demo Laptop configuration

As Azure Open AI, Azure AI Search and the Storage Account are only privatly exposed, you need to connect to them privately for configuration.
You can use the VPN Gateway deployed as part of this architecture by downloading the Client Certificate file of a user attached to it.
You will also need to add entries to your hosts file with the ouputs. Examples are :

```
a_open_ai_endpoint_name_hosts_file_entry = "10.147.70.102 aviatrix-ignite-cea-147.openai.azure.com"
b_ai_search_name_hosts_file_entry = "10.147.70.101 aviatrix-ignite-search-147.search.windows.net"
c_storage_account_hosts_file_entry = "10.147.70.100 eusavxignitesa76522.blob.core.windows.net"
```

Finally, if you want to search for DNS and TLS flows from the AWS application to the DNS and Open AI in Azure, you can filter in FlowIQ using

```
d_aws_instance_private_ip = "10.52.0.11" as a source ip address,
e_private_dns_resolver_inbound_endpoint_ip = "10.147.70.116" as a destination IP to find DNS related traffic (UDP/53)
f_private_endpoint_open_ai_ip = "10.147.70.102" as a destination IP to find HTTPS requests to Open AI (TCP/443) 
```

### Access the Application

1. **Update Index and Indexer configuration**  
   Update the index and indexers with the sample JSON at the end of this readme.

2. **Connect to EC2 Instance**:
   Using your own ssh key, login to the EC2 instance with user ubuntu
   ```bash
   ssh -i your-key.pem ubuntu@<instance-private-ip>
   ```

3. **Navigate to Application**:
   ```bash
   cd ~/sample-app-aoai-chatGPT
   ```

4. **Start Application**:
   Start the application. It will install all the pre-requisites and start a listener on port 50505 using HTTPS.
   ```bash
   ./start.sh
   ```

### DNS Configuration

The AWS EC2 instance is configured to use private DNS resolver inbound endpoint which is a private IP of the Azure VNET. It provides the below:
- Azure service name resolution,
- Cross-cloud DNS resolution,
- Private endpoint private IP resolution.

## Monitoring and Troubleshooting

### Network Connectivity and visibility

To demonstrate private connectivity between AWS and Azure:

- Open Aviatrix Copilot and go to the Monitoring/FlowIQ view.
- Search for traffic with source as the AWS EC2 instance (from the ouput) and port 53, protocol UDP
- Search for traffic with source as the AWS EC2 instance (from the ouput) and port 443, protocol TCP

These two searches will show 
- the AWS EC2 instance resolving DNS name to IP for the Azure Open AI private endpoint
- the AWS EC2 instance connecting of TCP 443 to the AZure Open AI private endpoint
- Traffic between AZure Open AI and Azure AI Search is done inside the Microsoft backbone using managed identities.

## Cleanup

```bash
terraform destroy
```

## Architecture Benefits

1. **Secure Cross-Cloud**: Private connectivity between AWS and Azure
2. **Scalable**: Aviatrix transit architecture supports multiple spokes
3. **Automated**: Complete infrastructure and application deployment
4. **Production-Ready**: Security groups, SSL certificates, and proper DNS
5. **Cost-Effective**: Single gateway deployment with HA options available

## Related Documentation

- [Aviatrix Documentation](https://docs.aviatrix.com/)
- [Microsoft OpenAI Sample App](https://github.com/microsoft/sample-app-aoai-chatGPT)
- [Azure AI Search Documentation](https://docs.microsoft.com/en-us/azure/search/)

## Index and Indexer configuration sample

This gives correct field for the Index and fields mapping.
Once index and indexer are created by Terraform, you can edit and provide the below JSONs.

## AI Search Index JSON
{
  "@odata.etag": "\"0x8DDFBA34DA85B85\"",
  "name": "oai-data-index",
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "searchable": false,
      "filterable": false,
      "retrievable": true,
      "stored": true,
      "sortable": false,
      "facetable": false,
      "key": true,
      "synonymMaps": []
    },
    {
      "name": "content",
      "type": "Edm.String",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "stored": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "analyzer": "standard.lucene",
      "synonymMaps": []
    },
    {
      "name": "embedding",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "stored": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "dimensions": 1536,
      "vectorSearchProfile": "vector-profile",
      "synonymMaps": []
    }
  ],
  "scoringProfiles": [],
  "suggesters": [],
  "analyzers": [],
  "normalizers": [],
  "tokenizers": [],
  "tokenFilters": [],
  "charFilters": [],
  "similarity": {
    "@odata.type": "#Microsoft.Azure.Search.BM25Similarity"
  },
  "semantic": {
    "configurations": [
      {
        "name": "semantic-conf",
        "flightingOptIn": false,
        "rankingOrder": "BoostedRerankerScore",
        "prioritizedFields": {
          "prioritizedContentFields": [
            {
              "fieldName": "content"
            }
          ],
          "prioritizedKeywordsFields": []
        }
      }
    ]
  },
  "vectorSearch": {
    "algorithms": [
      {
        "name": "defaultVectorAlgo",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "cosine",
          "m": 4,
          "efConstruction": 400,
          "efSearch": 500
        }
      }
    ],
    "profiles": [
      {
        "name": "vector-profile",
        "algorithm": "defaultVectorAlgo"
      }
    ],
    "vectorizers": [],
    "compressions": []
  }
}


# AI Search Indexer JSON
{
  "name": "aoi-indexer",
  "description": null,
  "dataSourceName": "oai-data-datasource",
  "skillsetName": null,
  "targetIndexName": "oai-data-index",
  "disabled": null,
  "schedule": null,
  "parameters": {
    "batchSize": null,
    "maxFailedItems": null,
    "maxFailedItemsPerBatch": null,
    "configuration": {
      "dataToExtract": "contentAndMetadata"
    }
  },
  "fieldMappings": [
    {
      "sourceFieldName": "content",
      "targetFieldName": "content",
      "mappingFunction": null
    }
  ],
  "outputFieldMappings": [],
  "cache": null,
  "encryptionKey": null
}