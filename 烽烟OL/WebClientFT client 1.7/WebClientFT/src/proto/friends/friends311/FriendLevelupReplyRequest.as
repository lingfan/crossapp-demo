package proto.friends.friends311 {
	import com.netease.protobuf.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	// @@protoc_insertion_point(imports)
	// @@protoc_insertion_point(class_metadata)
	public final class FriendLevelupReplyRequest extends Message implements IExternalizable {
		public var id:int;
		public var friendId:int;
		public var handleType:int;
		public function writeExternal(output:IDataOutput):void {
			WriteUtils.writeTag(output, WireType.VARINT, 1);
			WriteUtils.write_TYPE_INT32(output, id);
			WriteUtils.writeTag(output, WireType.VARINT, 2);
			WriteUtils.write_TYPE_INT32(output, friendId);
			WriteUtils.writeTag(output, WireType.VARINT, 3);
			WriteUtils.write_TYPE_INT32(output, handleType);
		}
		public function readExternal(input:IDataInput):void {
			var idCount:uint = 0;
			var friendIdCount:uint = 0;
			var handleTypeCount:uint = 0;
			while (input.bytesAvailable != 0) {
				var tag:Tag = ReadUtils.readTag(input);
				switch (tag.number) {
				case 1:
					if (idCount != 0) {
						throw new IOError('Bad data format.');
					}
					++idCount;
					id = ReadUtils.read_TYPE_INT32(input);
					break;
				case 2:
					if (friendIdCount != 0) {
						throw new IOError('Bad data format.');
					}
					++friendIdCount;
					friendId = ReadUtils.read_TYPE_INT32(input);
					break;
				case 3:
					if (handleTypeCount != 0) {
						throw new IOError('Bad data format.');
					}
					++handleTypeCount;
					handleType = ReadUtils.read_TYPE_INT32(input);
					break;
				default:
					ReadUtils.skip(input, tag.wireType);
				}
			}
			if (idCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (friendIdCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (handleTypeCount != 1) {
				throw new IOError('Bad data format.');
			}
		}
	}
}
